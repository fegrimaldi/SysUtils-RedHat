#!/bin/bash

# Shell colors
RED='\e[0;31m'
YELLOW='\e[0;33m'
CYAN='\e[0;36m'
LIGHT_GRAY='\e[0;37m'
END_COLOR='\e[0m'

if [ $(command -v dnf) ]; then
    INSTALL_CMD="dnf"
else
    INSTALL_CMD="yum"
fi

# Install required packages and enable servivces. Does not start them yet
printf "${YELLOW}Installing Apache and MySQL Packages and Enabling services.${END_COLOR}\n"
sudo ${INSTALL_CMD} install httpd httpd-devel mod_ssl mariadb-server mariadb-devel mod_security_crs -y
sudo systemctl enable httpd
sudo systemctl enable mariadb


# Add ports to FireWall Allow list
printf "${YELLOW}"
printf "Adding Web and DB Services to Firewall Allowed List.\n"
ACTIVE_ZONE=$(sudo  firewall-cmd --get-active-zone | head -n1 | sed -e 's/\s.*$//')
printf "Adding HTTP Protocol TCP Port 80.\n"
sudo firewall-cmd --zone=$ACTIVE_ZONE --add-service=http --permanent
printf "Adding HTTPS Protocol TCP Port 443.\n"
sudo firewall-cmd --zone=$ACTIVE_ZONE --add-service=https  --permanent
printf "Adding MySQL Server TCP Port 3306.\n"
sudo firewall-cmd --zone=$ACTIVE_ZONE --add-service=mysql --permanent
sudo firewall-cmd --reload
printf "${END_COLOR}"


# Create Web Server Administrator and Developer Groups
printf "${YELLOW}Creating Groups and Adding default Users.${END_COLOR}\n"
sudo groupadd webadmins
sudo groupadd webdevs

# Add Users to Administrator Groups
sudo usermod -a -G webadmins root
sudo usermod -a -G webadmins $USER

# Add Users to Web Developers Group
sudo usermod -a -G webdevs root
sudo usermod -a -G webdevs $USER
sudo usermod -a -G webdevs apache

printf "${YELLOW}Setting Up Web Directories.${END_COLOR}\n"
# Set Permissions on httpd base directories
if [ ! -d /var/www/html ]; then
    sudo mkdir -p /var/www/html
fi
sudo mkdir -p /var/www/webapps/default
sudo cp httpd_config/html/index.html /var/www/html/
sudo cp httpd_config/html/wsgi_test.py /var/www/webapps/default/
sudo chown root:webdevs -R /var/www
sudo chmod g+w -R /var/www

# Create PKI Directories Directories and copy openssl.conf
if [ -d /etc/httpd ]; then
    sudo mkdir -p /etc/httpd/pki/ssl/private
fi
sudo cp httpd_config/openssl.conf httpd_config/gen_csr.sh httpd_config/gen_self_signed_cert.sh /etc/httpd/pki/ssl/

# Creates sites-available if no present and copys default virtual hosts
if [ ! -d /etc/httpd/sites-available ]; then
    sudo mkdir -p /etc/httpd/sites-available
fi
sudo cp httpd_config/00-default.conf httpd_config/00-default-ssl.conf /etc/httpd/sites-available/

# Creates sites-enabled directory if it does not exist and enables virtual hosts
if [ ! -d /etc/httpd/sites-enabled ]; then
    sudo mkdir -p /etc/httpd/sites-enabled
fi
sudo ln -s /etc/httpd/sites-available/00-default.conf /etc/httpd/sites-enabled/default.conf
sudo ln -s /etc/httpd/sites-available/00-default-ssl.conf /etc/httpd/sites-enabled/default-ssl.conf

# Copy httpd conf files
if [ -d /etc/httpd/conf.d ]; then
    printf "${YELLOW}Copy Additional Apache Configs.${END_COLOR}\n"
    sudo cp httpd_config/security.conf /etc/httpd/conf.d/
fi

# Configure mod_security_crs
printf "${YELLOW}Configuring Mod Security OWASP Core Rule Set.${END_COLOR}\n"
if [ -d /etc/httpd/modsecurity.d/activated_rules ]; then
    sudo cp httpd_config/test_rule.conf /etc/httpd/modsecurity.d/activated_rules/
fi

# Reset Permissions
printf "${YELLOW}Resetting Permissions on directories...${END_COLOR}\n"
sudo chown root:webadmins -R /etc/httpd
sudo chmod g+w -R /etc/httpd

printf "${YELLOW}Starting Apache and MySQL Services.${END_COLOR}\n"
sudo systemctl start mariadb
sudo systemctl start httpd

IS_SSL_LOADED=$(sudo httpd -M | grep -i ssl)
IS_REWRITE_LOADED=$(sudo httpd -M | grep -i rewrite)
IS_H2_LOADED=$(sudo httpd -M | grep -i http2)
IS_SECURITY2_LOADED=$(sudo httpd -M | grep -i security2)


if  [ IS_SSL_LOADED ] ; then
    printf "${YELLOW}SSL Module is enabled.${END_COLOR}\n"
else
    printf "${RED}Note: SSL Module is not enabled.${END_COLOR}\n"
fi

if  [ IS_REWRITE_LOADED ] ; then
    printf "${YELLOW}Rewrite Module is enabled.${END_COLOR}\n"
else
    printf "${RED}Note: Rewrite Module is not enabled.${END_COLOR}\n"
fi

if  [ IS_H2_LOADED ] ; then
    printf "${YELLOW}HTTP2 Module is enabled.${END_COLOR}\n"
else
    printf "${RED}Note: HTTP2 Module is not enabled.${END_COLOR}\n"
fi

if  [ IS_SECURITY2_LOADED ] ; then
    printf "${YELLOW}Mod Security CRS is enabled.${END_COLOR}\n"
else
    printf "${RED}Note: Mod Security CRS  not enabled.${END_COLOR}\n"
fi



printf "${RED}Modifications have been made to groups and permissions. Log off, then back on before proceeding.${END_COLOR}\n"
