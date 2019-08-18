#!/bin/bash --init-file
# set -e
# set -x

### General Variables ###

SHELL_PROFILE="$HOME/.profile"
PYTHON_LOCAL_SCRIPTS="$HOME/.local/bin"

### Python Variables ###

DESIRED_PYTHON_VERSIONS='2.7.16 3.5.7 3.6.9 3.7.4'
TARGET_PYTHON_VERSION=${1:-${DESIRED_PYTHON_VERSIONS[@]:(-5)}}

PYTHON_COMMAND='python3'

######################
## Install python 3 ##
######################
apk add --no-cache $PYTHON_COMMAND

## Corroborate Python version
# which python

## Run Bourne Shell-compatible "bash" scripts in sh (within limitations e.g. not `shopt`)
## Mainly to avoid busybox embedded systems to install as dependency bash shell
# echo -e "#!/usr/bin/env sh\nsh \$@\n" > /usr/bin/bash && chmod a+x /usr/bin/bash

##########################################
## Install Pyenv-Installer dependencies ##
##########################################
apk add --no-cache --virtual .pyenv-deps git curl

## Install Python build dependencies
apk add --no-cache --virtual .build-deps bzip2-dev coreutils dpkg-dev dpkg expat-dev findutils gcc gdbm-dev libc-dev libffi-dev libnsl-dev libtirpc-dev linux-headers make ncurses-dev openssl openssl-dev pax-utils readline-dev sqlite-dev tcl-dev tk tk-dev util-linux-dev xz-dev zlib-dev

###################
## Install Pyenv ##
###################
curl -o- https://pyenv.run | bash

echo -e 'export PATH="$HOME/.pyenv/bin:$PATH"\neval "$(pyenv init -)"\neval "$(pyenv virtualenv-init -)"\n' >> $SHELL_PROFILE

## Install Pipenv
$PYTHON_COMMAND -m pip install --upgrade --user pipenv

## Install Poetry
$PYTHON_COMMAND -m pip install --upgrade --user poetry

echo -e "export PATH=$PYTHON_LOCAL_SCRIPTS:'\$PATH'\n" >> $SHELL_PROFILE
source $SHELL_PROFILE

## Install desired Python versions in parallel up to number of threads specified above
# Based on answer by PSkocik at Stackexchange here: https://unix.stackexchange.com/questions/103920/parallelize-a-bash-for-loop
(
for python_version in $DESIRED_PYTHON_VERSIONS; do
   pyenv install $python_version
done
)

git clone --depth=1 https://github.com/drconopoima/python-helloworld.git
(cd ./python-helloworld/ && $PYTHON_COMMAND ./helloworld.py && cd ..)
PYTHON3TEST=$?
(cd ./python-helloworld/ && pyenv virtualenv $TARGET_PYTHON_VERSION python-helloworld && pyenv activate python-helloworld && python ./helloworld.py && pyenv deactivate && pyenv uninstall -f python-helloworld && cd ..)
PYENVTEST=$?
(cd ./python-helloworld/ && $PYTHON_COMMAND -m pipenv install --python=$TARGET_PYTHON_VERSION && $PYTHON_COMMAND -m pipenv run ./helloworld.py && $PYTHON_COMMAND -m pipenv --rm && cd ..)
PIPENVTEST=$?
(cd ./python-helloworld/ && $PYTHON_COMMAND -m poetry install && $PYTHON_COMMAND -m poetry run ./helloworld.py && cd ..)
POETRYTEST=$?
rm -rf ./python-helloworld

if [ $PYTHON3TEST == 0 -a $PYENVTEST == 0 -a $PIPENVTEST == 0 -a $POETRYTEST == 0 ]; then
    echo "Script finished successfully. Python (System, Pyenv, Poetry and Pipenv) has been installed and configured."
else
   if [ $PYTHON3TEST != 0 ]; then
      echo "Script failed to install system Python3"
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
