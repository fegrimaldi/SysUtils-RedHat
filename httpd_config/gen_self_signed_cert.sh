#!/bin/bash

# Shell colors
RED='\e[0;31m'
YELLOW='\e[0;33m'
CYAN='\e[0;36m'
LIGHT_GRAY='\e[0;37m'
END_COLOR='\e[0m'

SSL_DIR="/etc/httpd/pki/ssl"
OPENSSL_CMD=$(sudo command -v openssl)

if [[ "$1" == "" || "$1" == "--help" ]]; then
    printf "${RED}Must specify cert name as a parameter.${END_COLOR}\n"
    printf "${YELLOW}Ex: gen_self_signed_cert.sh my_cert ${END_COLOR}\n"
    exit 1
else
    CERT_NAME=$1
    sudo ${OPENSSL_CMD} req -x509 -newkey rsa:2048 -keyout "$SSL_DIR"/private/"$CERT_NAME".key -nodes -out "$SSL_DIR"/"$CERT_NAME".cer -days 365 -config "$SSL_DIR"/openssl.conf
fi

printf "${YELLOW}Resetting Permissions.${END_COLOR}\n"
sudo chown root:webadmins -R /etc/httpd/ssl
sudo chmod 664 $SSL_DIR/"$CERT_NAME".cer
sudo chmod 664 $SSL_DIR/private/"$CERT_NAME".key