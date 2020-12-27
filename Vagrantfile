# -*- mode: ruby -*-
# vi: set ft=ruby :

# Server Configuration
base_box = "ubuntu/bionic64"
hostname = "williamium"

# Synced folder
host_projects_dir  = "P:/Sites"
guest_projects_dir = "/home/vagrant/sites"

# Set a local private network IP address.
# See http://en.wikipedia.org/wiki/Private_network for explanation
# You can use the following IP ranges:
#   10.0.0.1    - 10.255.255.254
#   172.16.0.1  - 172.31.255.254
#   192.168.0.1 - 192.168.255.254
server_ip       = "192.168.18.73"
server_cpus     = "2"   # Cores
server_memory   = "512" # MB
server_timezone = "Europe/London"

# can be altered to your prefered locale, see http://docs.moodle.org/dev/Table_of_locales
locale_language = "en_GB"
locale_codeset  = "en_GB.UTF-8"

# Database Configuration
mysql_version            = "5.7"  # Options: 5.7
mariadb_version          = "10.1" # Options: 10.0 | 10.1
mariadb_ubuntu_code_name = "bionic"
db_root_password         = "root" # We'll assume user "root"
db_enable_remote         = "true" # remote access enabled when true

# Languages and Packages
php_version  = "8.0"           # Options: 7.0 | 7.1 | 7.2 | 7.3 | 7.4 | 8.0
php_timezone = server_timezone # http://php.net/manual/en/timezones.php

Vagrant.configure("2") do |config|
  # Set server base box
  config.vm.box = base_box

  # Create a hostname, don't forget to put it to the `hosts` file
  # This will point to the server's default virtual host
  config.vm.hostname = hostname

  # Create a static IP
  config.vm.network "private_network", ip: server_ip
  # config.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true

  # Set shared folders
  config.vm.synced_folder ".", "/vagrant"
  config.vm.synced_folder host_projects_dir, guest_projects_dir

  # If using VirtualBox
  config.vm.provider :virtualbox do |vb|
    vb.name = "vagrant-" + config.vm.hostname

    vb.customize [
      "modifyvm", :id,
      "--pae", "on",
      "--cpus", server_cpus,
      "--memory", server_memory
    ]

    # Set the timesync threshold to 10 seconds, instead of the default 20 minutes.
    # If the clock gets more than 15 minutes out of sync (due to your laptop going
    # to sleep for instance, then some 3rd party services will reject requests.
    vb.customize ["guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000]

    # Prevent VMs running on Ubuntu to lose internet connection
    # vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    # vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end

  ####
  # Base Items
  ##########

  # Provision Base Packages
  config.vm.provision "shell", path: "scripts/base.sh", args: [hostname, locale_language, locale_codeset, server_timezone]

  # optimize base box
  config.vm.provision "shell", path: "scripts/base_box_optimisations.sh", privileged: true

  # Provision PHP
  config.vm.provision "shell", path: "scripts/php.sh", args: [php_timezone, php_version]


  ####
  # Web Servers
  ##########

  # Provision Nginx Base
  config.vm.provision "shell", path: "scripts/nginx.sh", args: [server_ip, guest_projects_dir, php_version]


  ####
  # Databases
  ##########

  # Provision MySQL
  config.vm.provision "shell", path: "scripts/mysql.sh", args: [db_root_password, mysql_version, db_enable_remote, guest_projects_dir]

  # Provision MariaDB
  # config.vm.provision "shell", path: "scripts/mariadb.sh", args: [db_root_password, mariadb_version, mariadb_ubuntu_code_name, db_enable_remote, guest_projects_dir]
end