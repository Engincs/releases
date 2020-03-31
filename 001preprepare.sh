#!/bin/sh

set -e

apt -y install build-essential autoconf bison flex texinfo help2man gawk libtool libncurses5-dev python3-dev python3-distutils git gettext libtool-bin libtool-doc 
apt -y install ncurses-dev bison texinfo flex autoconf automake libtool patch curl cvs build-essential subversion gawk gperf libncurses5-dev libexpat1-dev


cd /root
git clone https://github.com/crosstool-ng/crosstool-ng

cd /root/crosstool-ng

./bootstrap
echo "only build it and run from the source directory optional"
./configure --enable-local
echo "only make command and make install not required"
make
./ct-ng help
./ct-ng version

mkdir -v /root/src
mkdir -v /root/crosstool-ng/src

./ct-ng list-samples | grep x86_64
./ct-ng show-x86_64-unknown-linux-gnu
echo "Select x86_64-unknown-linux-gnu and customize"
# ./ct-ng x86_64-unknown-linux-gnu
# ./ct-ng menuconfig
# ./ct-ng build

#echo "Touch musl missing library files!"
echo "Launching apk update...."
apk update

echo "Creating virtual package for musl, musl-dev, musl-utils ..."
#apk add -t musl
#apk add -t musl-dev
#apk add -t musl-utils

#echo "Touch musl missing library files!"
