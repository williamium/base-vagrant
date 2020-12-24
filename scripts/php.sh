#!/usr/bin/env bash

# Install PHP
printf "\n\nInstalling PHP ($2)...\n"

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C

# Add repo for PHP
sudo add-apt-repository -y ppa:ondrej/php

sudo apt-key update
sudo apt-get update

php_service="php$2-fpm"
php_path="/etc/php/$2"

case $2 in
    "5.6"|"7.0"|"7.1")
        sudo apt-get install -y php$2-cli php$2-fpm php$2-common php$2-imap php$2-json php$2-zip php$2-mbstring php$2-dom php$2-mcrypt php$2-curl php$2-mysqlnd php$2-gd php$2-imagick php$2-memcached php$2-intl php$2-xdebug;;
    *)
        sudo apt-get install -y php$2-cli php$2-fpm php$2-common php$2-imap php$2-json php$2-zip php$2-mbstring php$2-dom php$2-curl php$2-mysqlnd php$2-gd php$2-imagick php$2-memcached php$2-intl php$2-xdebug;;
esac

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

# Install Composer
EXPECTED_SIGNATURE="$(wget -q -O - https://composer.github.io/installer.sig)"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_SIGNATURE="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]
then
    >&2 printf "ERROR: Invalid installer signature\n"
    rm composer-setup.php
    exit 1
fi

sudo php composer-setup.php --quiet --install-dir=/usr/local/bin --filename=composer
rm composer-setup.php

echo 'export PATH="$PATH:~/.composer/vendor/bin"' >> /home/vagrant/.bashrc

printf "Composer installed\n"

##### Complete #####
printf "\n\nPHP provisioning complete.\n"