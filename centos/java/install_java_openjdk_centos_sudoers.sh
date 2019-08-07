#!/bin/sh

DESIRED_UTF8_LOCALE='en_US.UTF-8'

####################
## Java Variables ##
####################

# JAVA_VERSION='java-1.7.0-openjdk'
JAVA_VERSION='java-1.8.0-openjdk'
# JAVA_VERSION='java-11-openjdk'

## Java Packages: Install JRE in production or JDK for development. Defaults to JDK

## JRE Production
# JAVA_PACKAGE="${JAVA_VERSION}"

## JDK Development
JAVA_PACKAGE="${JAVA_VERSION}-devel"

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

sudo yum install -y $JAVA_PACKAGE

echo -e "\nexport JAVA_HOME='/usr/lib/jvm/${JAVA_VERSION}/'\n" >> $SHELL_PROFILE
source $SHELL_PROFILE

## Switch between different versions

# sudo yum install alternatives

# /usr/sbin/alternatives --config java

echo "Script execution finished successfully."
