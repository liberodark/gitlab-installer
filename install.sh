#!/bin/bash
#
# About: Install Gitlab automatically
# Author: liberodark
# License: GNU GPLv3

version="0.0.3"

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

echo "What version Download ? Ex : 13.8.0"
read -r version

echo "What editon Download ? Ex : ee or ce"
read -r edition

install_rhel(){
      echo "Downloading $name-$version-$edition"
      wget -O "$name-$version-$edition.rpm" "https://packages.gitlab.com/gitlab/$name-$edition/packages/el/7/$name-$edition-$version-$edition.0.el7.x86_64.rpm/download.rpm" &> /dev/null
      echo "Install $name-$version-$edition"
      yum localinstall "$name-$version-$edition.rpm" -y > "$name-$version.log"
      echo "Clean $name-$version-$edition"
      rm -f "$name-$version-$edition.rpm"
      }


check_run(){
echo "Install Gitlab EE Server ($distribution)"

  # Check OS

if [[ "$distribution" = CentOS || "$distribution" = CentOS || "$distribution" = Red\ Hat || "$distribution" = Fedora || "$distribution" = Suse || "$distribution" = Oracle ]]; then
      install_rhel || exit

fi
}

check_run
