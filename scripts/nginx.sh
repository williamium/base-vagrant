#!/usr/bin/env bash

# Install Nginx
printf "\n\nInstalling Nginx...\n"

# Test if PHP is installed
php -v > /dev/null 2>&1
PHP_IS_INSTALLED=$?

php_service="php$3-fpm"

[[ -z $1 ]] && { echo "!!! IP address not set. Check the Vagrant file.\n"; exit 1; }

# Add repo for latest stable nginx
sudo add-apt-repository -y ppa:ondrej/nginx

# Add repo for latest mainline nginx
# sudo add-apt-repository -y ppa:ondrej/nginx-mainline

# Update Again
sudo apt-get update

# Install Nginx
sudo apt-get install -y nginx

# Set run-as user for PHP5-FPM processes to user/group "vagrant"
# to avoid permission errors from apps writing to files
sed -i "s/user www-data;/user vagrant;/" /etc/nginx/nginx.conf
sed -i "s/# server_names_hash_bucket_size.*/server_names_hash_bucket_size 64;/" /etc/nginx/nginx.conf

# Add vagrant user to www-data group
usermod -a -G www-data vagrant

# Nginx enabling and disabling virtual hosts
sudo wget -P /usr/bin https://raw.githubusercontent.com/perusio/nginx_ensite/master/bin/nginx_ensite
sudo wget -P /usr/bin https://raw.githubusercontent.com/perusio/nginx_ensite/master/bin/nginx_dissite

# Need to add execute permissions to those scripts
sudo chmod ugo+x /usr/bin/nginx_*

# Each project will have its nginx config stored in a vagrant/nginx directory so copy that over like we did with apache config below
# My mysql init.sql import script may help with this (looping over the folders etc)
for path in $2/*; do
    if [ -d "${path}" ]; then
        dirname="$(basename "${path}")"

        if [ -f $path/vagrant/nginx/*.conf ]; then
            conf_file="$(basename "${path}"/vagrant/nginx/*.conf)"
            filename=${conf_file%.*}

            sudo cp ${path}"/vagrant/nginx/"$filename.conf /etc/nginx/sites-available/
            sudo nginx_ensite $filename.conf

            printf "Nginx config imported for $dirname...\n"
        else
            printf "No Nginx config to import for $dirname...\n"
        fi
    fi
done

if [[ $PHP_IS_INSTALLED -eq 0 ]]; then
    # PHP-FPM Config for Nginx
    sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/$3/fpm/php.ini

    sudo service $php_service restart
fi

sudo service nginx restart

##### Complete #####
printf "\n\nNginx provisioning complete.\n"