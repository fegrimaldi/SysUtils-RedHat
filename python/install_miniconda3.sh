#!/bin/bash

#!/bin/bash

# Shell colors
RED='\e[0;31m'
YELLOW='\e[0;33m'
CYAN='\e[0;36m'
LIGHT_GRAY='\e[0;37m'
END_COLOR='\e[0m'

printf "${YELLOW}Installing Miniconda to /usr/share/miniconda3.${END_COLOR}\n"
sudo ./Miniconda3-latest-Linux-x86_64.sh -b -p /usr/share/miniconda3 && \

printf "${YELLOW}Modifying permissions on /usr/share/miniconda3.${END_COLOR}\n"
sudo chown root:webdevs -R /usr/share/miniconda3 && \
sudo chmod g+w -R /usr/share/miniconda3 && \

if [ -w /usr/share/miniconda3 ]; then
    printf "${YELLOW} Directory is writeable by current process. Proceeding...${END_COLOR}\n"
else
    printf "${RED} Directory is NOT writeable by current process. Terminating.${END_COLOR}\n"
    exit 1
fi
printf "${YELLOW}Activating Miniconda3.${END_COLOR}\n"
source /usr/share/miniconda3/bin/activate && \

printf "${YELLOW}Initializing zsh with conda.${END_COLOR}\n"
conda init zsh && \

printf "${YELLOW}Updating Conda and Python Versions.${END_COLOR}\n"
conda update conda -y && \
conda update python -y && \

printf "${YELLOW}Installing base python modules.${END_COLOR}\n"
pip install -r python_base_reqs.txt

printf "${YELLOW}Cloning Env Base to apache-wsgi.${END_COLOR}\n"
conda create -n apache-wsgi --clone base && \

printf "${YELLOW}Activating apache-wsgi and installing Django WSGI Modules.${END_COLOR}\n"
conda activate apache-wsgi && \
pip install -r django_reqs.txt
