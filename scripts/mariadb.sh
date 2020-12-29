#!/usr/bin/env bash

echo ">>> Installing MariaDB"

[[ -z $1 ]] && { echo "!!! MariaDB root password not set. Check the Vagrant file."; exit 1; }

# Import repo key
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db

# Add repo for MariaDB
sudo add-apt-repository "deb [arch=amd64,i386,ppc64el] http://mirrors.coreix.net/mariadb/repo/$2/ubuntu $3 main"

# Update
sudo apt-get update

# Install MariaDB without password prompt
# Set username to 'root' and password to 'mariadb_root_password' (see Vagrantfile)
sudo debconf-set-selections <<< "maria-db-$2 mysql-server/root_password password $1"
sudo debconf-set-selections <<< "maria-db-$2 mysql-server/root_password_again password $1"

# Install MariaDB
# -qq implies -y --force-yes
sudo apt-get install -qq mariadb-server

# Make Maria connectable from outside world without SSH tunnel
if [ $4 == "true" ]; then
    printf "\n\nConfiguring remote MySQL access...\n"

    # enable remote access
    # setting the mysql bind-address to allow connections from everywhere
    sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

    # adding grant privileges to mysql root user from everywhere
    # thx to http://stackoverflow.com/questions/7528967/how-to-grant-mysql-privileges-in-a-bash-script for this
    Q1="GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY '$1' WITH GRANT OPTION;"
    Q2="FLUSH PRIVILEGES;"
    SQL="${Q1}${Q2}"

    mysql -uroot -p$1 -e "$SQL"
fi

sudo service mysql restart

# Check for SQL files to import
for path in $5/*; do
    if [ -d "${path}" ]; then
        dirname="$(basename "${path}")"

        if [ -f $path/vagrant/db/init/*.sql ]; then
            sql_file="$(basename "${path}"/vagrant/db/init/*.sql)"
            filename=${sql_file%.*}
            # Convert any . (dots) in the filename to underscores (you can't have dots in a database name)
            db_name=${filename//./_}

            mysql -uroot -p$1 -e "CREATE DATABASE IF NOT EXISTS $db_name"
            mysql -uroot -p$1 $filename < ${path}"/vagrant/db/init/"$filename.sql

            printf "Database created & imported for $dirname...\n"
        else
            printf "No database to import for $dirname...\n"
        fi
    fi
done

##### Complete #####
printf "\n\MariaDB provisioning complete. Remember to dump the database before destroying the VM by using the following SQL:\n
mysqldump -uroot -p$1 DBNAME > /path/to/project/vagrant/db/dump/dump.sql\n"