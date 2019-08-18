#!/usr/bin/env sh

###################
## Update Alpine ##
###################
apk update && apk upgrade

##################
## Install Bash ##
##################
apk add --no-cache bash

##########################
## Run Companion Script ##
##########################
COMPANION_FILE='./install_python_alpine_root.sh'

if test -f "$COMPANION_FILE"; then
    /bin/bash ./install_python_alpine_root.sh
else
    wget -qo- https://raw.githubusercontent.com/drconopoima/sysadmin_devops_scripts/master/alpine/python/install_python_alpine_root.sh | /bin/bash --init-file
fi
