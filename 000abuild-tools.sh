#!/bin/bash
set -e
# Runme on U(x)buntu 19.10

TARGET_ARCH=$1
# HINT: Look at cat /etc/apk/arch 
if [ -z "$TARGET_ARCH" ]; then
 printf 'Please enter target architecture\n'
 printf 'On an x86/64 machine, selecting other archs like arm, mips etc will return error\n\n'
 printf 'x86 BASED\n'
 printf 'x86 - 32 bit x86 (ia32)\n'
 printf 'x86_64 - 64 bit x86 (amd64)\n\n'
 printf 'ARM BASED\n'
 printf 'armhf - 32 bit ARM (hard-float ABI)\n'
 printf 'aarch64 - 64 bit ARM\n\n'
 printf 'POWERPC BASED\n'
 printf 'ppc64le - 64 bit PowerPC (little-endian)\n\n'
 printf 'MIPS BASED\n'
 printf 'mips64\n\n'
 printf 'IBM SYSTEM Z BASED\n'
 printf 's390x\n\n'
 return 1
fi

STORAGE=/root/storage
STORAGE_APK=/root/storage/apk

CHROOT=/root/abuild-tools
if [[ ! -e $CHROOT ]]; then
    mkdir $CHROOT
elif [[ ! -d $CHROOT ]]; then
    echo "$CHROOT already exists but is not a directory, discontinuing" 1>&2
    return 1
fi

STORAGE=/root/storage
if [[ ! -e $STORAGE ]]; then
    mkdir $STORAGE
elif [[ ! -d $STORAGE ]]; then
    echo "$STORAGE Common storage already exists but is not a directory, discontinuing" 1>&2
    return 1
fi

# Getting read for Glibc port of Alpine - Test script only
cd /root/

apt -y install build-essential autoconf bison flex texinfo help2man gawk libtool libncurses5-dev python3-dev python3-distutils git gettext libtool-bin libtool-doc 
apt -y install ncurses-dev bison texinfo flex autoconf automake libtool patch curl cvs build-essential subversion gawk gperf libncurses5-dev libexpat1-dev
apt-get install zlib1g-dev
apt-get install libssl-dev

echo "Getting apktools static version 64-bit"
export APKTOOLSVERSION=2.10.5-r0
wget http://dl-cdn.alpinelinux.org/alpine/edge/main/$TARGET_ARCH/apk-tools-static-$APKTOOLSVERSION.apk

echo "Untar apktools static version 64-bit"
tar -xzf apk-tools-static-*.apk
cp sbin/apk.static apk
rm -rf apk-tools-static-*.apk
rm -rf sbin/

echo "Creating chroot with busybox, alpine-keys and apk-tools"
#./apk -X http://dl-cdn.alpinelinux.org/alpine/edge/main/ -U --allow-untrusted --root /root/engincs-os-chroot/ --initdb add busybox-static apk-tools-static alpine-keys
./apk -X http://dl-cdn.alpinelinux.org/alpine/edge/main/ -U --allow-untrusted --arch $TARGET_ARCH --root $CHROOT --initdb add busybox-static apk-tools-static alpine-keys linux-headers

echo "Binding and mounting dev, proc and sys"
mkdir $CHROOT/sys
mount /dev/ $CHROOT/dev/ --bind
mount -o remount,ro,bind $CHROOT/dev
mount -t proc none $CHROOT/proc 
mount -o bind /sys $CHROOT/sys

echo "Creating root directory"
mkdir -p $CHROOT/root

echo "creating resolv.conf"
cp /etc/resolv.conf $CHROOT/etc/ 
#echo -e 'nameserver 8.8.8.8\nnameserver 2620:0:ccc::2' > /root/engincs-os-chroot/etc/resolv.conf
printf 'nameserver 8.8.8.8\nnameserver 2620:0:ccc::2' > $CHROOT/etc/resolv.conf

echo "creating repositories folder"
mkdir -p $CHROOT/etc/apk 
printf 'http://dl-cdn.alpinelinux.org/alpine/edge/main/\nhttp://dl-cdn.alpinelinux.org/alpine/edge/community/\nhttp://dl-cdn.alpinelinux.org/alpine/edge/testing/' > $CHROOT/etc/apk/repositories

echo "Chroot and generate busybox symbolic links"
#chroot /root/engincs-os-chroot/ busybox.static sh
chroot $CHROOT /bin/busybox.static --install -s /bin
#exit
echo "Exited chroot"

echo "moving apk required for abuild"
mv $CHROOT/sbin/apk.static $CHROOT/sbin/apk

echo "Creating comming storage directory"
mkdir -p $CHROOT/root/storage
echo "Binding common storage to engincs os storage"
mount -o bind $STORAGE $CHROOT/root/storage

echo "Clone aports and fetch the latest updates"
if [[ ! -e $STORAGE_APK ]]; then
    mkdir $STORAGE_APK
elif [[ ! -d $STORAGE_APK ]]; then
    echo "$STORAGE aports already cloned discontinuing" 1>&2
    return 1
fi
cd /root/storage
git clone https://gitlab.alpinelinux.org/alpine/aports.git
cd /root/storage/aports
git pull 


cd /root/storage

# x86_64
FILE=/root/storage/x86-64-core-i7--glibc--bleeding-edge-2020.02-2.tar.bz2
if [ -f "$FILE" ]; then
    echo "$FILE exists"
else 
    echo "$FILE does not exist"
    wget https://toolchains.bootlin.com/downloads/releases/toolchains/x86-64-core-i7/tarballs/x86-64-core-i7--glibc--bleeding-edge-2020.02-2.tar.bz2
    tar xf x86-64-core-i7--glibc--bleeding-edge-2020.02-2.tar.bz2
fi

# aarch64
# wget https://toolchains.bootlin.com/downloads/releases/toolchains/aarch64/tarballs/aarch64--glibc--bleeding-edge-2020.02-2.tar.bz2

echo "Copy tools to common storage"
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

echo "Sleeping for 10s....."
# To sleep for .5 seconds: 
sleep 10s
#mount - commented out for abuild to run properly
#umount /root/engincs-os-chroot/dev
#umount /root/engincs-os-chroot/proc
#umount /root/engincs-os-chroot/sys
#mount
