#!/usr/bin/env bash

# Install PHP
printf "\n\nInstalling PHP ($2)...\n"

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C

# Add repo for PHP
sudo add-apt-repository -y ppa:ondrej/php

sudo apt-key update
sudo apt-get update

if [ $2 == "5.6" ]; then
    php_service="php5.6-fpm"
    php_path="/etc/php/5.6"
    sudo apt-get install -y php5.6-cli php5.6-fpm php5.6-common php5.6-imap php5.6-json php5.6-xml php5.6-mcrypt php5.6-curl php5.6-mysqlnd php5.6-gd php5.6-imagick php5.6-memcached php5.6-intl php5.6-xdebug
elif [ $2 == "7.0" ]; then
    php_service="php7.0-fpm"
    php_path="/etc/php/7.0"
    sudo apt-get install -y php7.0-cli php7.0-fpm php7.0-common php7.0-imap php7.0-json php7.0-xml php7.0-mcrypt php7.0-curl php7.0-mysqlnd php7.0-gd php7.0-imagick php7.0-memcached php7.0-intl php7.0-xdebug
elif [ $2 == "7.1" ]; then
    php_service="php7.1-fpm"
    php_path="/etc/php/7.1"
    sudo apt-get install -y php7.1-cli php7.1-fpm php7.1-common php7.1-imap php7.1-json php7.1-xml php7.1-mcrypt php7.1-curl php7.1-mysqlnd php7.1-gd php7.1-imagick php7.1-memcached php7.1-intl php7.1-xdebug
fi

# php7.1-fpm
# /etc/php/7.1/{mods-available,fpm,etc}
# listen = /run/php/php7.1-fpm.sock

##### PHP Configuration #####
printf "\n\nPHP configuration...\n"
sudo sed -i '$a opcache.revalidate_freq = 0' $php_path/mods-available/opcache.ini

# Set PHP FPM to listen on TCP instead of Socket
# Listens on /var/run/php5-fpm.sock by default
# sudo sed -i "s/listen =.*/listen = 127.0.0.1:9000/" $php_path/fpm/pool.d/www.conf

# Set PHP FPM allowed clients IP address
sudo sed -i "s/;listen.allowed_clients/listen.allowed_clients/" $php_path/fpm/pool.d/www.conf

# Set run-as user for PHP5-FPM processes to user/group "vagrant"
# to avoid permission errors from apps writing to files
sudo sed -i "s/user = www-data/user = vagrant/" $php_path/fpm/pool.d/www.conf
sudo sed -i "s/group = www-data/group = vagrant/" $php_path/fpm/pool.d/www.conf

sudo sed -i "s/listen\.owner.*/listen.owner = vagrant/" $php_path/fpm/pool.d/www.conf
sudo sed -i "s/listen\.group.*/listen.group = vagrant/" $php_path/fpm/pool.d/www.conf
sudo sed -i "s/listen\.mode.*/listen.mode = 0666/" $php_path/fpm/pool.d/www.conf

# xdebug config
cat > $(find ${php_path} -name xdebug.ini) << EOF
zend_extension=xdebug.so
xdebug.remote_enable = 1
xdebug.remote_connect_back = 1
xdebug.remote_port = 9000
xdebug.scream=0
xdebug.cli_color=1
xdebug.show_local_vars=1

; var_dump display
xdebug.var_display_max_depth = 5
xdebug.var_display_max_children = 256
xdebug.var_display_max_data = 1024
EOF

# PHP Error Reporting config
sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" $php_path/fpm/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" $php_path/fpm/php.ini

# PHP timezone
sudo sed -i "s/;date.timezone =.*/date.timezone = ${1/\//\\/}/" $php_path/fpm/php.ini
sudo sed -i "s/;date.timezone =.*/date.timezone = ${1/\//\\/}/" $php_path/cli/php.ini

sudo service $php_service restart

##### Complete #####
printf "\n\nPHP provisioning complete.\n"