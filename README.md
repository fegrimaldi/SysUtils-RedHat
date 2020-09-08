# Orion Microtechnology Red Hat Linux Based System Utilities
## For CentOS, RedHat, and Fedora Linux

### Base Installation
Installs Red Hat Based Linux additional tools required for installation of a Web Server and the Orion Shell.
    
    install_base_packages.sh

### The Orion Shell
Sets up the Orion Shell, based on ZSH. oh-my-zsh, spaceship prompt, plus tweaks your .zshrc profile with Orion Microtechnology shell tweaks.
    
    setup_orion_shell.sh

### Apache and MySQL (MariaDb)
Installs and configures basic settings of the Apache Web Server, including mod_security_crs which feature the OWASP Core Rule Set, then installs MariaDB (MySQL). 
    
    install_apache_mysql.sh

Creates **/var/www/html** and **/var/www/webapps/default**. It copies an **index.html** and copies a **test_wsgi.py script** to the **webapps/default** directory.

### Install Miniconda Python
Installs miniconda3 python, creates base and apache-wsgi environments to be used for the apache web server.

    python/install_miniconda3.sh

The script will install miniconda3 to **/usr/share/miniconda3**. Having it in this directory won't prevent SELinux from blocking the loading of mod_wsgi and it's linked libraries. The script it make the directory writeable to the webadmins group. 

Further, the script will install base modules I find essential. Then, it will clone the 'base' environment to apache-wsgi and proceed to to install the modules required for a Django and GUnicorn based WSGI server.
