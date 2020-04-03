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

# Clone aports and fetch the latest updates
cd /root/
git clone https://gitlab.alpinelinux.org/alpine/aports.git
cd /root/aports
git pull 

# Static compile abuild
# Note: If we pass -no-pie to GCC on Alpine, its binary will not be PIE-enabled just like Ubuntu binary isn't PIE-enabled, 
# but then it will be statically linked as we want
# Do not attemp on glibc as libc uses libnss to support a number of different providers for address resolution services.
# Unfortunately, we cannot statically link libnss, as exactly what providers it loads depends on the local system's configuration
# Hence below command will fail in glibc systems even with enable --enable-static-nss

cd /root
git clone https://git.alpinelinux.org/cgit/abuild/
cd /root/abuild
CFLAGS="-no-pie -static" make
