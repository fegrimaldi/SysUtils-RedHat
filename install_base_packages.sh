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

# Update OS and Install Red Hat Base Packages
printf "${YELLOW} Updating OS and Installing Base Packages.${END_COLOR}\n"
sudo ${INSTALL_CMD} update -y && \
sudo ${INSTALL_CMD} install zsh tree net-tools git fontconfig \
    wget policycoreutils-python-utils -y
sudo ${INSTALL_CMD} group install "Development Tools" -y

# Configure SSH Server: Regenerate Keys
printf "${YELLOW}Reconfiguring SSH Server.${END_COLOR}\n"
sudo rm -v /etc/ssh/ssh_host_* && \
sudo ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa && \
sudo ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa && \
sudo ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa -b 521 && \

# Generate User Keys
printf "${YELLOW}Generating SSH Keys for User: $USER.${END_COLOR}\n"
ssh-keygen

printf "${RED}It is recommend that you reboot the system now.${END_COLOR}\n"
printf "${Yellow}Remember to run ssh-keygen -R <hostname> on your workstation before connecting via ssh again.${END_COLOR}\n"