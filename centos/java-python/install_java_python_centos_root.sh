#!/bin/sh

#######################
## General Variables ##
#######################

SHELL_PROFILE="/etc/bashrc"
NUMBER_OF_THREADS=8
DESIRED_UTF8_LOCALE='en_US.UTF-8'

######################
## Python Variables ##
######################

DESIRED_PYTHON_VERSIONS='2.7.16 3.4.10 3.5.7 3.6.9 3.7.4'

# PYTHON_COLLECTION_VERSION='27'
# PYTHON_COLLECTION_VERSION='34'
# PYTHON_COLLECTION_VERSION='35'
PYTHON_COLLECTION_VERSION='36'

PYTHON_PACKAGE_COLLECTION="rh-python${PYTHON_COLLECTION_VERSION}"

####################
## Java Variables ##
####################

### JRE
# JAVA_VERSION='java-1.7.0-openjdk'
# JAVA_VERSION='java-1.8.0-openjdk'
# JAVA_VERSION='java-11-openjdk'

## JDK Development
# JAVA_VERSION='java-1.7.0-openjdk-devel'
JAVA_VERSION='java-1.8.0-openjdk-devel'
# JAVA_VERSION='java-11-openjdk-devel'

###################
## Update CentOS ##
###################
yum update -y
####################
## Manage locales ##
####################
## To list locales
# locale -a
## Other locales 
## Locale en_US.UTF-8 may be overriden by the configuration of YUM. To circumvent this:
## First Delete the line that overrides conf:
# sed -i.bak '/override_install_langs/d' /etc/yum.conf && \
## It gets backed up to /etc/yum.conf.bak
## Finally reinstall glibc-common for being able to change the locale
# yum reinstall glibc-common 
## Change LOCALE #
echo -e "\nexport LC_ALL=$DESIRED_UTF8_LOCALE\nexport LANG=$DESIRED_UTF8_LOCALE\nexport LANGUAGE=$DESIRED_UTF8_LOCALE\n" >> $SHELL_PROFILE
source $SHELL_PROFILE

############################################################################################################################
##                                                   JAVA                                                                 ##
############################################################################################################################

yum install -y $JAVA_VERSION

echo -e "\nexport JAVA_HOME='/usr/lib/jvm/${JAVA_VERSION}/'\n" >> $SHELL_PROFILE
source $SHELL_PROFILE

yum install alternatives

## Switch between different versions

# /usr/sbin/alternatives --config java

############################################################################################################################
##                                                 PYTHON                                                                 ##
############################################################################################################################

######################
## install Python 3 ##
######################
yum install -y @development
yum install -y centos-release-scl
yum install -y $PYTHON_PACKAGE_COLLECTION

## Install PyENV dependencies
yum install zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel \
openssl-devel xz xz-devel libffi-devel findutils -y

## Enable RHSCL Python collection environment session (inc. variables python3, python36, pip3. Variable python will point to version of the installed collection)
## Add RHSCL Python For a single session
# scl enable $PYTHON_COLLECTION_VERSION bash
## Add RHSCL Python 3 by default to all login sessions
echo -e "source scl_source enable $PYTHON_PACKAGE_COLLECTION\n" >> $SHELL_PROFILE
source $SHELL_PROFILE

## Corroborate Python version
# which python

## Install Pipenv
PIP_COMMAND=(pip${PYTHON_COLLECTION_VERSION})
$PIP_COMMAND install --upgrade pipenv

## Install Pyenv

curl https://pyenv.run | bash
echo -e '\nexport PATH="~root/.pyenv/bin:$PATH"\neval "$(pyenv init -)"\neval "$(pyenv virtualenv-init -)"\n' >> $SHELL_PROFILE
source $SHELL_PROFILE

## Install desired Python versions in parallel up to number of threads specified above
# Based on answer by PSkocik at Stackexchange here: https://unix.stackexchange.com/questions/103920/parallelize-a-bash-for-loop
(
for python_version in $DESIRED_PYTHON_VERSION; do
   ((i=i%NUMBER_OF_THREADS)); ((i++==0)) && wait 
   pyenv install "$python_version" &
done
)

wait

echo "Script execution finished successfully."
