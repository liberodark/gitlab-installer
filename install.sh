
#!/bin/bash
#
# About: Install Gitlab automatically
# Author: liberodark
# License: GNU GPLv3

version="0.0.1"

echo "Welcome on Gitlab Install Script $version"

#=================================================
# CHECK ROOT
#=================================================

if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

#=================================================
# RETRIEVE ARGUMENTS FROM THE MANIFEST AND VAR
#=================================================

distribution=$(cat /etc/*release | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print $1}')
name=gitlab-ee
version=12.1.12
edition=ee

install_rhel(){
      echo "Downloading $name-$version-$edition"
      wget -O "$name-$version-$edition.rpm" "https://packages.gitlab.com/gitlab/gitlab-ee/packages/el/7/$name-$version-$edition.0.el7.x86_64.rpm/download.rpm" &> /dev/null
      echo "Install $name-$version-$edition"
      yum localinstall $name-$version-$edition.rpm -y &> /dev/null
      echo "Clean $name-$version-$edition"
      sudo rm $name-$version-$edition.rpm*
      }


check_run(){
echo "Install Gitlab EE Server ($distribution)"

  # Check OS

if [[ "$distribution" = CentOS || "$distribution" = CentOS || "$distribution" = Red\ Hat || "$distribution" = Fedora || "$distribution" = Suse || "$distribution" = Oracle ]]; then
      #yum install -y make gcc glibc glibc-common openssl openssl-devel PackageKit &> /dev/null

      install_rhel || exit
    
    elif [[ "$distribution" = Debian || "$distribution" = Ubuntu || "$distribution" = Deepin ]]; then
      apt-get update &> /dev/null
      apt-get install -y make autoconf automake gcc libc6 libmcrypt-dev libssl-dev openssl packagekit --force-yes &> /dev/null
    
      compile_nrpe_ssl || exit
      
    elif [[ "$distribution" = Clear ]]; then
      swupd bundle-add make c-basic-legacy openssl devpkg-openssl ansible packagekit &> /dev/null
    
      compile_nrpe_ssl || exit
      
    elif [[ "$distribution" = Manjaro || "$distribution" = Arch\ Linux ]]; then
      pacman -S make autoconf automake gcc glibc libmcrypt  openssl packagekit --noconfirm &> /dev/null
    
      compile_nrpe_ssl || exit

    fi
}

check_run
