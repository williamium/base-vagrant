# -*- mode: ruby -*-
# vi: set ft=ruby :

# Server Configuration
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
server_memory   = "384" # MB
server_timezone = "Europe/London"

# can be altered to your prefered locale, see http://docs.moodle.org/dev/Table_of_locales
locale_language = "en_GB"
locale_codeset  = "en_GB.UTF-8"

# Database Configuration
mysql_root_password = "root" # We'll assume user "root"
mysql_version       = "5.5"  # Options: 5.5 | 5.6
mysql_enable_remote = "true" # remote access enabled when true

# Languages and Packages
php_timezone = server_timezone # http://php.net/manual/en/timezones.php
php_version  = "5.5"           # Options: 5.5 | 5.6

nodejs_version  = "latest"   # By default "latest" will equal the latest stable version
nodejs_packages = [          # List any global NodeJS packages that you want to install
  #"gulp",
  #"bower",
]

Vagrant.configure("2") do |config|
  # Set server to Ubuntu 14.04
  config.vm.box = "ubuntu/trusty64"

  if Vagrant.has_plugin?("vagrant-hostmanager")
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline = false
  end

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
    vb.name = "vagrant_"+config.vm.hostname

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

  # If using Vagrant-Cachier
  # http://fgrehm.viewdocs.io/vagrant-cachier
  if Vagrant.has_plugin?("vagrant-cachier")
    # Configure cached packages to be shared between instances of the same base box.
    # Usage docs: http://fgrehm.viewdocs.io/vagrant-cachier/usage
    config.cache.scope = :box

    config.cache.synced_folder_opts = {
      type: :nfs,
      mount_options: ['rw', 'vers=3', 'tcp', 'nolock']
    }
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
  config.vm.provision "shell", path: "scripts/nginx.sh", args: [server_ip, guest_projects_dir]


  ####
  # Databases
  ##########

  # Provision MySQL
  config.vm.provision "shell", path: "scripts/mysql.sh", args: [mysql_root_password, mysql_version, mysql_enable_remote, guest_projects_dir]

  # Provision MariaDB
  # config.vm.provision "shell", path: "scripts/mariadb.sh", args: [mysql_root_password, mysql_enable_remote, guest_projects_dir]


  ####
  # In-Memory Stores
  ##########

  # Install Memcached
  # config.vm.provision "shell", path: "scripts/memcached.sh"


  ####
  # Additional Languages
  ##########

  # Install Nodejs
  # config.vm.provision "shell", path: "scripts/nodejs.sh", privileged: false, args: nodejs_packages.unshift(nodejs_version)
end