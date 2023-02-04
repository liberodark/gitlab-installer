#!/bin/bash
# About: Install Gitlab automatically
# Author: liberodark
# License: GNU GPLv3

version_script="0.0.8"
echo "Welcome on Gitlab Install Script $version_script"

# Check Root
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

# Define variables
distribution=$(cat /etc/*release | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print $1}')
name="gitlab"
v=$(cat /etc/*release | grep "VERSION_ID" | sed 's/VERSION_ID=//g' | sed 's/["]//g' | cut -f1 -d".")

# Function to display usage information
usage ()
{
     echo "Usage: script -e ce -v 13.8.0"
     echo "Options:"
     echo "-e: ce or ee"
     echo "-v: 13.8.0"
     echo "-h: Show help"
}

# Function to set edition
set_edition()
{
    edition="$1"

    # Validate input
    if [ "$edition" != "ce" ] && [ "$edition" != "ee" ]; then
        echo "Error: Invalid edition specified"
        usage
        exit 1
    fi
}

# Function to set version
set_version()
{
    version="$1"
}

# Function to install GitLab on Red Hat-based distributions
install_rhel()
{
    echo "Downloading $name-$version-$edition"
    wget -O "$name-$version-$edition.rpm" "https://packages.gitlab.com/gitlab/$name-$edition/packages/el/$v/$name-$edition-$version-$edition.0.el$v.x86_64.rpm/download.rpm" &> /dev/null
    echo "Install $name-$version-$edition"
    yum localinstall "$name-$version-$edition.rpm" -y
    echo "Upgrade PostgreSQL"
    gitlab-ctl pg-upgrade
    echo "Restart GitLab"
    gitlab-ctl restart
    echo "Clean up"
    rm -f "$name-$version-$edition.rpm"
    # Check installed version
    check_version=$(cat /opt/gitlab/version-manifest.txt | head -n 1)
    echo "New version is: $check_version"
    echo "Deploy the GitLab page and reconfigure"
    gitlab-ctl deploy-page down
    gitlab-ctl reconfigure
}

# Function to check run and install GitLab
check_run()
{
    echo "Installing GitLab $edition Server $version ($distribution)"

    # Check OS
    if [ "$distribution" = "CentOS" ] || [ "$distribution" = "AlmaLinux" ] || [ "$distribution" = "Rocky" ] || [ "$distribution" = "Red\ Hat" ] || [ "$distribution" = "Oracle" ]; then
        install_rhel || exit
    else
        echo "Error: Unsupported distribution: $distribution"
        exit 1
    fi
}

# Function to parse arguments
parse_args()
{
    while [ $# -ne 0 ]; do
        case "$1" in
            -e)
                shift
                set_edition "$1"
                ;;
            -v)
                shift
                set_version "$1"
                install_rhel
                ;;
            -h|--help)
                usage
                ;;
            *)
                echo "Invalid argument : ${1}" >&2
                usage >&2
                exit 1
                ;;
        esac
        shift
    done

}

parse_args "$@"
