#!/usr/bin/env bash

##### Server Configuration #####

# Hostname
printf "\n\nSetting hostname...\n"
sudo hostname $1

# Set Locale, see https://help.ubuntu.com/community/Locale#Changing_settings_permanently
printf "\n\nSetting locale...\n"
sudo locale-gen $2 $3

# Set timezone, for un-attended info see https://help.ubuntu.com/community/UbuntuTime#Using_the_Command_Line_.28unattended.29
printf "\n\nSetting timezone...\n"
echo $4 | sudo tee /etc/timezone
sudo dpkg-reconfigure --frontend noninteractive tzdata

# Download and update package lists
printf "\n\nPackage manager updates...\n"
sudo apt-get update -y
sudo apt-get upgrade -y

# Install or update nfs-common to the latest release
printf "\n\nInstalling base packages...\n"
sudo apt-get install -y nfs-common curl make openssl unzip zip checkinstall

##### Complete #####
printf "\n\nBase provisioning complete.\n"