#!/bin/sh
set -e
# Runme inside previously built chroot /root/abuild-tools/ sh
export FORCE_UNSAFE_CONFIGURE=1 
apk update
# vi /etc/ssh/sshd_config
# rc-status
# rc-service sshd restart

apk add alpine-sdk
apk add build-base
apk add bash
apk add curl
apk add zlib
apk add vim
apk add openssl-dev
apk add zlib-dev
apk add musl-dev
apk add zlib-static
apk add openssl-libs-static
apk add perl
apk add linux-headers attr-dev acl-static # required for tar

# vi /etc/passwd change from root:x:0:0:root:/root:/bin/ash to root:x:0:0:root:/root:/bin/bash

# Static compile abuild
# Note: If we pass -no-pie to GCC on Alpine, its binary will not be PIE-enabled just like Ubuntu binary isn't PIE-enabled, 
# but then it will be statically linked as we want
# Do not attemp on glibc as libc uses libnss to support a number of different providers for address resolution services.
# Unfortunately, we cannot statically link libnss, as exactly what providers it loads depends on the local system's configuration
# Hence below command will fail in glibc systems even with enable --enable-static-nss

echo "Compiling static version of abuild"
cd /root/storage
git clone https://git.alpinelinux.org/cgit/abuild/
cd /root/storage/abuild
CFLAGS="-no-pie -static" make
gcc -no-pie -static -O3 -o abuild-fetch abuild-fetch.c -I/usr/include /usr/lib/libc.a 
gcc -no-pie -static -O3 -o abuild-gzsplit abuild-gzsplit.c -I/usr/include /lib/libz.a /usr/lib/libc.a 
gcc -no-pie -static -O3 -o abuild-sudo abuild-sudo.c -I/usr/include /usr/lib/libc.a 
gcc -no-pie -static -O3 -o abuild-tar abuild-tar.c -I/usr/include /usr/lib/libcrypto.a /usr/lib/libc.a 
gcc -no-pie -static -O3 -o abuild-rmtemp abuild-rmtemp.c -I/usr/include /usr/lib/libc.a

# Order is not really important but the dependencies needed to be able to build are more important
# To build userspace programs, first need to be build compilers, libraries etc
# Run the following in in aports/main
# bzip2 is first, it has no dependencies at all, same with zlib, perl only depends on those 2 packages

echo "Generating build order"
apk add lua-aports
cd /root/storage/aports/main
ap builddirs * > /root/storage/build-order.log

echo "Compiling wget version"
#apt install gnutls-bin libgnutls-openssl27 libcurl4-gnutls-dev libpsl-dev libgnutls28-dev
apk add gnutls gnutls-dev gnutls-utils
cd /root/storage
wget https://ftp.gnu.org/gnu/wget/wget-1.20.3.tar.gz
tar xvzf wget-1.20.3.tar.gz #may encounter extraction error, hence try this in host environment
cd wget-1.20.3
env CPPFLAGS="-I/usr/include" LDFLAGS="-L/usr/lib/ssl" ./configure --with-ssl=openssl
make CPPFLAGS="-I/usr/include" LDFLAGS="-L/usr/lib -L/usr/lib/ssl -no-pie -static"

echo "Compiling static version of openssl"
wget https://www.openssl.org/source/openssl-1.1.1f.tar.gz
tar zxvf openssl-1.1.1f.tar.gz
cd /root/storage/openssl-1.1.1f
# Configure
# CC='/usr/bin/gcc -static -static-libgcc' ./Configure no-shared no-async linux-x86_64
# CC='/usr/bin/gcc -static' ./Configure no-shared no-async linux-x86_64
CC='/usr/bin/gcc -no-pie -static -static-libgcc' ./Configure no-shared no-async linux-x86_64
CFLAGS="-no-pie -static -static-libgcc" LDFLAGS="-static" make -j12
# Build 
# make -j12

echo "Compiling static version of tar to common storage"
wget https://ftp.gnu.org/gnu/tar/tar-1.32.tar.gz
tar xvzf tar-1.32.tar.gz
cd /root/storage/tar-1.32
# ./configure --prefix=/usr --disable-nls --libexecdir=/usr/bin
./configure --prefix=/usr --libexecdir=/usr/lib --enable-static --disable-shared --disable-rpath
make CFLAGS='-no-pie -static'

echo "Compiling static version of pax-utils (scanelf)"
wget https://gitweb.gentoo.org/proj/pax-utils.git/snapshot/pax-utils-1.2.5.tar.gz
make CFLAGS='-no-pie -static'

apk add ncurses ncurses-dev
echo "Compile busybox"
wget https://busybox.net/downloads/snapshots/busybox-20200408.tar.bz2
tar xf busybox-20200408.tar.bz2
cd busybox
make defconfig
make menuconfig

echo "===============COMPILE INSIDE CHROOT==========================="
echo "Compiling static version of patch"
wget https://ftp.gnu.org/gnu/patch/patch-2.7.6.tar.gz
tar xvzf patch-2.7.6.tar.gz
./configure
./make -j12

echo "===============COMPILE INSIDE CHROOT==========================="
echo "Compiling static version of attr to common storage"
wget http://download.savannah.gnu.org/releases/attr/attr-2.4.48.tar.gz
tar xvzf attr-2.4.48.tar.gz
cd attr-2.4.48
./configure --prefix=/usr --enable-static --disable-shared
make LDFLAGS=-static

# BUILD AND COPY TO COMMON STORAGE
# 0. Abuild
# 3. wget - not required
# 5. openssl/libressl - static compile in alpine


