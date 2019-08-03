#!/bin/sh

DESIRED_UTF8_LOCALE='en_US.UTF-8'

### JRE
# JAVA_VERSION='java-1.7.0-openjdk'
# JAVA_VERSION='java-1.8.0-openjdk'
## JAVA_VERSION='java-11-openjdk'

## JDK Development
# JAVA_VERSION='java-1.7.0-openjdk-devel'
JAVA_VERSION='java-1.8.0-openjdk-devel'
# JAVA_VERSION='java-11-openjdk-devel'

###################
## Update CentOS ##
###################
sudo yum update -y
####################
## Manage locales ##
####################
## To list locales
# locale -a
## Other locales 
## Locale en_US.UTF-8 may be overriden by the configuration of sudo yum. To circumvent this:
## First Delete the line that overrides conf:
# sed -i.bak '/override_install_langs/d' /etc/sudo yum.conf && \
## It gets backed up to /etc/sudo yum.conf.bak
## Finally reinstall glibc-common for being able to change the locale
# sudo yum reinstall glibc-common 
## Change LOCALE #
echo -e "\nexport LC_ALL=$DESIRED_UTF8_LOCALE\nexport LANG=$DESIRED_UTF8_LOCALE\nexport LANGUAGE=$DESIRED_UTF8_LOCALE\n" >> $SHELL_PROFILE
source $SHELL_PROFILE
############################################################################################################################

sudo yum install -y $JAVA_VERSION

echo -e "\nexport JAVA_HOME='/usr/lib/jvm/${JAVA_VERSION}/'\n" >> $SHELL_PROFILE
source $SHELL_PROFILE

sudo yum install alternatives

## Switch between different versions

# /usr/sbin/alternatives --config java

echo "Script execution finished successfully."
