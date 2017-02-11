#!/usr/bin/env bash

# Install PHP
printf "\n\nInstalling PHP ($2)...\n"

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C

if [ $2 == "5.5" ]; then
    # Add repo for PHP 5.5
    sudo add-apt-repository -y ppa:ondrej/php5
else
    # Add repo for PHP 5.6
    sudo add-apt-repository -y ppa:ondrej/php5-5.6
fi

sudo apt-key update
sudo apt-get update

sudo apt-get install -y php5-cli php5-fpm php5-common php5-imap php5-json php5-mcrypt php5-curl php5-mysqlnd php5-gd php5-imagick php5-memcached php5-intl php5-xdebug

##### PHP Configuration #####
printf "\n\nPHP configuration...\n"
sudo sed -i '$a opcache.revalidate_freq = 0' /etc/php5/mods-available/opcache.ini

# Set PHP FPM to listen on TCP instead of Socket
# Listens on /var/run/php5-fpm.sock by default
# sudo sed -i "s/listen =.*/listen = 127.0.0.1:9000/" /etc/php5/fpm/pool.d/www.conf

# Set PHP FPM allowed clients IP address
sudo sed -i "s/;listen.allowed_clients/listen.allowed_clients/" /etc/php5/fpm/pool.d/www.conf

# Set run-as user for PHP5-FPM processes to user/group "vagrant"
# to avoid permission errors from apps writing to files
sudo sed -i "s/user = www-data/user = vagrant/" /etc/php5/fpm/pool.d/www.conf
sudo sed -i "s/group = www-data/group = vagrant/" /etc/php5/fpm/pool.d/www.conf

sudo sed -i "s/listen\.owner.*/listen.owner = vagrant/" /etc/php5/fpm/pool.d/www.conf
sudo sed -i "s/listen\.group.*/listen.group = vagrant/" /etc/php5/fpm/pool.d/www.conf
sudo sed -i "s/listen\.mode.*/listen.mode = 0666/" /etc/php5/fpm/pool.d/www.conf

# xdebug config
cat > $(find /etc/php5 -name xdebug.ini) << EOF
zend_extension=$(find /usr/lib/php5 -name xdebug.so)
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
sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/fpm/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/fpm/php.ini

# PHP timezone
sudo sed -i "s/;date.timezone =.*/date.timezone = ${1/\//\\/}/" /etc/php5/fpm/php.ini
sudo sed -i "s/;date.timezone =.*/date.timezone = ${1/\//\\/}/" /etc/php5/cli/php.ini

sudo service php5-fpm restart

##### Complete #####
printf "\n\nPHP provisioning complete.\n"