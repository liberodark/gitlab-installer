#!/bin/bash
#
# About: Install Gitlab automatically
# Author: liberodark
# License: GNU GPLv3

version="0.0.7"

echo "Welcome on Gitlab Install Script $version"

#=================================================
# CHECK ROOT
#=================================================

if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

#=================================================
# RETRIEVE ARGUMENTS FROM THE MANIFEST AND VAR
#=================================================

distribution=$(cat /etc/*release | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print $1}')
name=gitlab
v=8

echo "What version Download ? Ex : 13.8.0"
read -r version

echo "What editon Download ? Ex : ee or ce"
read -r edition

install_rhel(){
      echo "Downloading $name-$version-$edition"
      wget -O "$name-$version-$edition.rpm" "https://packages.gitlab.com/gitlab/$name-$edition/packages/el/$v/$name-$edition-$version-$edition.0.el$v.x86_64.rpm/download.rpm" &> /dev/null
      echo "Install $name-$version-$edition"
      yum localinstall "$name-$version-$edition.rpm" -y
      echo "Upgrade PostgreSQL $name-$version-$edition"
      gitlab-ctl pg-upgrade
      echo "Complete install $name-$version-$edition"
      gitlab-ctl restart
      echo "Clean $name-$version-$edition"
      rm -f "$name-$version-$edition.rpm"
      check_version=$(cat /opt/gitlab/version-manifest.txt | head -n 1)
      echo "New version is : $check_version"
      gitlab-ctl deploy-page down
      gitlab-ctl reconfigure
      }


check_run(){
echo "Install Gitlab $edition Server ($distribution)"

  # Check OS

if [ "$distribution" = "CentOS" ] || [ "$distribution" = "AlmaLinux" ] || [ "$distribution" = "Rocky" ] || [ "$distribution" = "Red\ Hat" ] || [ "$distribution" = "Oracle" ]; then
      install_rhel || exit

fi
}

check_run
