#!/usr/bin/env bash

##### Server Configuration #####

# Hostname
printf "\n\nSetting hostname...\n"
sudo hostname $1

# Set Locale, see https://help.ubuntu.com/community/Locale#Changing_settings_permanently
printf "\n\nSetting locale...\n"
sudo locale-gen $2 $3

# Set timezone
printf "\n\nSetting timezone...\n"
sudo timedatectl set-timezone $4
timedatectl

# Download and update package lists
printf "\n\nPackage manager updates...\n"
sudo apt-get update -y
sudo apt-get upgrade -y

# Install or update nfs-common to the latest release
printf "\n\nInstalling base packages...\n"
sudo apt-get install -y nfs-common curl make openssl unzip zip checkinstall

##### Complete #####
printf "\n\nBase provisioning complete.\n"