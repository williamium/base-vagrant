#!/usr/bin/env bash

##### Provision LAMP Stack #####

printf "\n\nInstalling MySQL server ($2)...\n"

[[ -z $1 ]] && { echo "!!! MySQL root password not set. Check the Vagrant file.\n"; exit 1; }

# See http://dev.mysql.com/downloads/repo/apt/ for the repo to add on a real server
# The matching guide here: https://dev.mysql.com/doc/mysql-apt-repo-quick-guide/en/
# A tutorial here: http://www.devopsservice.com/installation-of-mysql-server-5-7-on-ubuntu-14-04/
mysql_package=mysql-server

if [ $2 == "5.6" ]; then
    # Add repo for MySQL 5.6
    sudo add-apt-repository -y ppa:ondrej/mysql-5.6

    # Update Again
    sudo apt-get update

    # Change package
    mysql_package=mysql-server-5.6
fi

# Install MySQL without password prompt. Info on unattended install: http://serverfault.com/questions/19367
# Set username and password
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $1"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $1"

sudo apt-get install -y $mysql_package

# Make MySQL connectable from outside world without SSH tunnel
if [ $3 == "true" ]; then
    printf "\n\nConfiguring remote MySQL access...\n"

    # enable remote access
    # setting the mysql bind-address to allow connections from everywhere
    sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

    # adding grant privileges to mysql root user from everywhere
    # thx to http://stackoverflow.com/questions/7528967/how-to-grant-mysql-privileges-in-a-bash-script for this
    MYSQL=`which mysql`

    Q1="GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY '$1' WITH GRANT OPTION;"
    Q2="FLUSH PRIVILEGES;"
    SQL="${Q1}${Q2}"

    $MYSQL -uroot -p$1 -e "$SQL"
fi

sudo service mysql restart

# Check for SQL files to import
for path in $4/*; do
    if [ -d "${path}" ]; then
        dirname="$(basename "${path}")"

        if [ -f $path/vagrant/db/init/*.sql ]; then
            sql_file="$(basename "${path}"/vagrant/db/init/*.sql)"
            filename=${sql_file%.*}
            # Convert any . (dots) in the filename to underscores (you can't have dots in a database name)
            db_name=${filename//./_}

            $MYSQL -uroot -p$1 -e "CREATE DATABASE IF NOT EXISTS $db_name"
            $MYSQL -uroot -p$1 $filename < ${path}"/vagrant/db/init/"$filename.sql

            printf "Database created & imported for $dirname...\n"
        else
            printf "No database to import for $dirname...\n"
        fi
    fi
done

##### Complete #####
printf "\n\nMySQL provisioning complete. Remember to dump the database before destroying the VM by using the following SQL:\n
mysqldump -uroot -proot DBNAME > /path/to/project/vagrant/db/dump/dump.sql\n"