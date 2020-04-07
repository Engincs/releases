#!/bin/sh
set -e
# Runme on U(x)buntu 19.10

echo "Copying tools patch, scanelf from pax-utils"
cd /root/storage
cp /usr/bin/patch /root/storage
cp /usr/bin/scanelf /root/storage

echo "Compiling static version of attr to common storage"
cd /root/storage
wget http://download.savannah.gnu.org/releases/attr/attr-2.4.48.tar.gz
tar xvzf attr-2.4.48.tar.gz
cd /root/storage/attr-2.4.48
./configure --prefix=/usr --enable-static --disable-shared
make LDFLAGS=-static

echo "Compiling static version of tar to common storage"
apt -y install libacl1-dev libattr1-dev
cd /root/storage
wget https://ftp.gnu.org/gnu/tar/tar-1.32.tar.gz
tar xvzf tar-1.32.tar.gz
cd /root/storage/tar-1.32
./configure --prefix=/usr --disable-nls --libexecdir=/usr/bin
make LDFLAGS=-static

cd /root/storage
#1. patch - copy - patch
#2. pax-utils - copy - scanelf
#4. tar - (libattr, libacl, tar) - static compile in host
#6. attr (on host)

echo "Build busybox"
# echo "Chroot and run apk update"
# chroot $CHROOT/ /bin/sh -l
# apk update
# exit
# echo "Exited chroot"
