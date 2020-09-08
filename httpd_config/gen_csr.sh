#!/bin/bash

# Shell colors
RED='\e[0;31m'
YELLOW='\e[0;33m'
CYAN='\e[0;36m'
LIGHT_GRAY='\e[0;37m'
END_COLOR='\e[0m'

SSL_DIR="/etc/httpd/ssl"
OPENSSL_CMD="/usr/bin/openssl"

if [ "$1" == "" || "$1" == "--help" ]; then
    printf "${RED}Must specify cert name as a parameter.${END_COLOR}\n"
    printf "${YELLOW}Ex: gen_csr.sh my_cert${END_COLOR}\n"
    exit 1
else
    printf "${YELLOW}Generating Certificate Signing Request...${END_COLOR}\n"
    sudo ${OPENSSL_CMD} req -out $SSL_DIR/"$1".cer -new -newkey rsa:2048 -nodes -keyout $SSL_DIR/private/"$1" -config $SSL_DIR/openssl.conf

fi

printf "${YELLOW}Resetting Permissions.${END_COLOR}\n"
sudo chown root:webadmins -R /etc/httpd/ssl
sudo chmod 664 $SSL_DIR/"$1".cer
sudo chmod 664 $SSL_DIR/private/"$1".key