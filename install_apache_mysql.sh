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

# Install required packages, enable, and start servivces
sudo ${INSTALL_CMD} install httpd httpd-devel mod_ssl mariadb-server mariadb-devel -y
sudo  systemctl enable httpd
sudo systemctl start httpd
sudo systemctl enable mariadb
sudo systemctl start mariadb

# Add ports to FireWall Allow list
printf "${YELLOW}"
printf "dding Web and DB Services to Firewall Allowed List.\n"
ACTIVE_ZONE=$(sudo  firewall-cmd --get-active-zone | head -n1 | sed -e 's/\s.*$//')
printf "Adding HTTP Protocol TCP Port 80"
sudo firewall-cmd --zone=$ACTIVE_ZONE --add-service=http --permanent
printf "Adding HTTPS Protocol TCP Port 443 .\n"
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
    sudo cp html/* /var/www/html/
    sudo chown root:webdevs -R /var/www
    sudo chmod 644 -R /var/www
fi


if [ -d /etc/httpd ]; then
    sudo mkdir -p /etc/httpd/ssl/private
    sudo cp openssl.conf /etc/httpd/ssl/
    sudo chown root:webadmins -R /etc/httpd
    sudo chmod g+w -R /etc/httpd
fi

IS_SSL_LOADED=$(sudo httpd -M | grep -i ssl)
IS_REWRITE_LOADED=$(sudo httpd -M | grep -i rewrite)
IS_H2_LOADED=$(sudo httpd -M | grep -i http2)

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

