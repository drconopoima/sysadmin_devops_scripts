#!/usr/bin/env bash
# set -e
set -x

#######################
## General Variables ##
#######################

SHELL_PROFILE="$HOME/.bash_profile"
SHELL_RC="$HOME/.bashrc"
NUMBER_OF_THREADS=8
DESIRED_UTF8_LOCALE='en_US.UTF-8'

######################
## Python Variables ##
######################

DESIRED_PYTHON_VERSIONS='2.7.16 3.5.7 3.6.9 3.7.4'

PYTHON_COLLECTION_VERSION='36'
# PYTHON_COLLECTION_VERSION='27'
# PYTHON_COLLECTION_VERSION='34'
# PYTHON_COLLECTION_VERSION='35'

PYTHON_PACKAGE_COLLECTION="rh-python${PYTHON_COLLECTION_VERSION}"

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
## Locale en_US.UTF-8 may be overriden by the configuration of yum. To circumvent this:
## First Delete the line that overrides conf:
# sed -i.bak '/override_install_langs/d' /etc/yum.conf
## It gets backed up to /etc/yum.conf.bak
## Finally reinstall glibc-common for being able to change the locale
# sudo yum reinstall glibc-common 
## Change LOCALE #
echo -e "\nexport LC_ALL=$DESIRED_UTF8_LOCALE\nexport LANG=$DESIRED_UTF8_LOCALE\nexport LANGUAGE=$DESIRED_UTF8_LOCALE\n" >> $SHELL_PROFILE
source $SHELL_PROFILE

############################################################################################################################
##                                                   JAVA                                                                 ##
############################################################################################################################

sudo yum install -y $JAVA_PACKAGE

echo -e "\nexport JAVA_HOME='/usr/lib/jvm/${JAVA_VERSION}/'\n" >> $SHELL_PROFILE
source $SHELL_PROFILE

## Switch between different versions

# sudo yum install alternatives

# /usr/sbin/alternatives --config java

############################################################################################################################
##                                                 PYTHON                                                                 ##
############################################################################################################################

######################
## install Python 3 ##
######################
sudo yum install -y centos-release-scl
sudo yum install -y $PYTHON_PACKAGE_COLLECTION

## Install PyENV dependencies
sudo yum install -y @development zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel xz xz-devel libffi-devel findutils

## Enable RHSCL Python collection environment session (inc. variables python3, python36, pip3. Variable python will point to version of the installed collection)
## Add RHSCL Python For a single session
# scl enable $PYTHON_COLLECTION_VERSION bash
## Add RHSCL Python 3 by default to all login sessions
echo -e "source scl_source enable $PYTHON_PACKAGE_COLLECTION\n" >> $SHELL_RC
source scl_source enable $PYTHON_PACKAGE_COLLECTION

## Corroborate Python version
# which python
PYTHON_COMMAND=(python$(echo $PYTHON_COLLECTION_VERSION | cut -c 1))

## Install Pipenv
sudo yum install -y which
$PYTHON_COMMAND -m pip install --upgrade --user pipenv

## Install Poetry
$PYTHON_COMMAND -m pip install --upgrade --user poetry

## Install Pyenv
curl https://pyenv.run | bash
echo -e '\nexport PATH="$HOME/.pyenv/bin:$PATH"\neval "$(pyenv init -)"\neval "$(pyenv virtualenv-init -)"\n' >> $SHELL_RC
source $SHELL_RC

## Install desired Python versions in parallel up to number of threads specified above
# Based on answer by PSkocik at Stackexchange here: https://unix.stackexchange.com/questions/103920/parallelize-a-bash-for-loop
(
for python_version in $DESIRED_PYTHON_VERSION; do
   ((i=i%NUMBER_OF_THREADS)); ((i++==0)) && wait 
   pyenv install "$python_version" &
done
)

wait

(curl -q -o HelloWorld.java https://introcs.cs.princeton.edu/java/11hello/HelloWorld.java && javac HelloWorld.java && java HelloWorld && rm -rf HelloWorld.java && rm -rf HelloWorld.class)
JAVATEST=$?
git clone --depth=1 https://github.com/drconopoima/python-helloworld.git
(cd ./python-helloworld/ && $PYTHON_COMMAND ./helloworld.py && cd ..)
PYTHON3SCLTEST=$?
(cd ./python-helloworld/ && pyenv virtualenv python-helloworld && pyenv activate python-helloworld && python ./helloworld.py && pyenv deactivate && pyenv uninstall -f python-helloworld && cd ..)
PYENVTEST=$?
(cd ./python-helloworld/ && $PYTHON_COMMAND -m pipenv install && $PYTHON_COMMAND -m pipenv run ./helloworld.py && $PYTHON_COMMAND -m pipenv --rm && cd ..)
PIPENVTEST=$?
(cd ./python-helloworld/ && $PYTHON_COMMAND -m poetry install && $PYTHON_COMMAND -m poetry run ./helloworld.py && cd ..)
POETRYTEST=$?
rm -rf python-helloworld/

if [ $JAVATEST == 0 -a $PYTHON3SCLTEST == 0 -a $PYENVTEST == 0 -a $PIPENVTEST == 0 -a $POETRYTEST == 0 ]; then
    echo "Script finished successfully. Java and Python (Software collection, Pyenv, Poetry and Pipenv) have been installed and configured."
else
   if [ $JAVATEST != 0 ]; then
     rm -rf HelloWorld.java
     echo "Script failed to install Java"
   fi
   if [ $PYTHON3SCLTEST != 0 ]; then
      echo "Script failed to configure Python3 from Centos Software Collection"
   fi
   if [ $PYENVTEST != 0 ]; then
      echo "Script failed to install Pyenv"
   fi
   if [ $PIPENVTEST != 0 ]; then
      echo "Script failed to install Pipenv"
   fi
   if [ $POETRYTEST != 0 ]; then
      echo "Script failed to install Poetry"
   fi
fi
