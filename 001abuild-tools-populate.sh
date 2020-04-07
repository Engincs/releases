#!/bin/sh
set -e
# Runme inside previously built chroot
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

# vi /etc/passwd change from root:x:0:0:root:/root:/bin/ash to root:x:0:0:root:/root:/bin/bash

# Static compile abuild
# Note: If we pass -no-pie to GCC on Alpine, its binary will not be PIE-enabled just like Ubuntu binary isn't PIE-enabled, 
# but then it will be statically linked as we want
# Do not attemp on glibc as libc uses libnss to support a number of different providers for address resolution services.
# Unfortunately, we cannot statically link libnss, as exactly what providers it loads depends on the local system's configuration
# Hence below command will fail in glibc systems even with enable --enable-static-nss

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

apk add lua-aports
cd /root/aports/main
ap builddirs * > /root/storage/build-order.log

echo "Build busybox"

# BUILD AND COPY TO COMMON STORAGE
# 0. Abuild
# 1. patch - copy - patch
# 2. pax-utils - copy - scanelf
# 3. wget - not required
# 4. tar - (libattr, libacl, tar) - static compile in host
# 5. openssl/libressl - static compile in alpine
# 6. attr (on host)
