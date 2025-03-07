#!/bin/bash

## Download and install RStudio server & dependencies uses.
##
## In order of preference, first argument of the script, the RSTUDIO_VERSION variable.
## ex. stable, preview, daily, 1.3.959, 2021.09.1+372, 2021.09.1-372, 2022.06.0-daily+11

set -e

RSTUDIO_VERSION=${1:-${RSTUDIO_VERSION:-"stable"}}
DEFAULT_USER=${DEFAULT_USER:-"rstudio"}

# shellcheck source=/dev/null
source /etc/os-release

# a function to install apt packages only if they are not installed
function apt_install() {
    if ! dpkg -s "$@" >/dev/null 2>&1; then
        if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
            apt-get update
        fi
        DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$@"
    fi
}

apt_install \
    ca-certificates \
    lsb-release \
    file \
    git \
    libapparmor1 \
    libclang-dev \
    libcurl4-openssl-dev \
    libedit2 \
    libobjc4 \
    libssl-dev \
    libpq5 \
    psmisc \
    procps \
    python3-setuptools \
    pwgen \
    sudo \
    wget

ARCH=$(dpkg --print-architecture)

## install s6 supervisor
#/rocker_scripts/install_s6init.sh

apt-get install dialog apt-utils -y
wget http://snapshot.debian.org/archive/debian/20190501T215844Z/pool/main/g/glibc/multiarch-support_2.28-10_amd64.deb
dpkg -i multiarch-support*.deb
wget http://snapshot.debian.org/archive/debian/20170705T160707Z/pool/main/o/openssl/libssl1.0.0_1.0.2l-1%7Ebpo8%2B1_amd64.deb
dpkg -i libssl1.0.0*.deb

wget https://www.openssl.org/source/openssl-1.1.1l.tar.gz
tar -xzvf openssl-1.1.1l.tar.gz
cd openssl-1.1.1l
./config --prefix=$HOME/local/openssl --openssldir=$HOME/local/openssl
make
make install

echo 'export LD_LIBRARY_PATH=$HOME/local/openssl/lib:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc

ln -s libssl.so.1.1 /lib/libssl.so.1.1
cd

apt install gdebi-core -y
wget https://download2.rstudio.org/server/focal/amd64/rstudio-server-2023.12.0-369-amd64.deb
