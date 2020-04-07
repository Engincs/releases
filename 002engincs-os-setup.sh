#!/bin/sh
set -e
# Runme on U(x)buntu 19.10
CHROOT=/root/abuild-tools
ENGINCS_OS=/root/engincs-os
if [ ! -e $ENGINCS_OS ]; then
    mkdir $ENGINCS_OS
elif [ ! -d $ENGINCS_OS ]; then
    echo "$ENGINCS_OS already exists but is not a directory, returning to prompt" 1>&2
    return 1
fi

# build new chroot
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

echo "umounting dev/proc/sys"

if mount|grep $CHROOT/dev; then
  echo "dev's mounted."
  umount $CHROOT/dev
else
  echo "dev's not mounted."
if

if mount|grep $CHROOT/sys; then
  echo "sys's mounted."
  umount $CHROOT/sys
else
  echo "sys's not mounted."
if

if mount|grep $CHROOT/proc; then
  echo "proc's mounted."
  umount $CHROOT/proc
else
  echo "proc's not mounted."
if

# Getting read for Glibc port of Alpine - Test script only
cd /root/

echo "Getting apktools static version 64-bit"
export APKTOOLSVERSION=2.10.5-r0
wget http://dl-cdn.alpinelinux.org/alpine/edge/main/$TARGET_ARCH/apk-tools-static-$APKTOOLSVERSION.apk

echo "Untar apktools static version 64-bit"
tar -xzf apk-tools-static-*.apk
cp sbin/apk.static apk
rm -rf apk-tools-static-*.apk
rm -rf sbin/

echo "Creating chroot with busybox, alpine-keys and apk-tools"
./apk -X http://dl-cdn.alpinelinux.org/alpine/edge/main/ -U --allow-untrusted --arch $TARGET_ARCH --root $ENGINCS_OS --initdb add busybox-static apk-tools-static alpine-keys linux-headers

echo "Binding and mounting dev, proc and sys"
mkdir $ENGINCS_OS/sys
mount /dev/ $ENGINCS_OS/dev/ --bind
mount -o remount,ro,bind $ENGINCS_OS/dev
mount -t proc none $ENGINCS_OS/proc 
mount -o bind /sys $ENGINCS_OS/sys

echo "Creating root directory"
mkdir -p $ENGINCS_OS/root

echo "creating resolv.conf"
cp /etc/resolv.conf /root/new-engincs-os-chroot/etc/ 
#echo -e 'nameserver 8.8.8.8\nnameserver 2620:0:ccc::2' > /root/new-engincs-os-chroot/etc/resolv.conf
printf 'nameserver 8.8.8.8\nnameserver 2620:0:ccc::2' > /root/new-engincs-os-chroot/etc/resolv.conf

echo "creating repositories folder"
mkdir -p $ENGINCS_OS/etc/apk 
printf 'http://dl-cdn.alpinelinux.org/alpine/edge/main/\nhttp://dl-cdn.alpinelinux.org/alpine/edge/community/\nhttp://dl-cdn.alpinelinux.org/alpine/edge/testing/' > $ENGINCS_OS/etc/apk/repositories

echo "Chroot and generate busybox symbolic links"
#chroot /root/engincs-os-chroot/ busybox.static sh
chroot $ENGINCS_OS/ /bin/busybox.static --install -s /bin
#exit
echo "Exited chroot"

echo "moving apk required for abuild"
mv $ENGINCS_OS/sbin/apk.static $ENGINCS_OS/sbin/apk

STORAGE=/root/storage
echo "Creating common storage directory"
mkdir -p $ENGINCS_OS/root/storage
echo "Binding common storage to engincs os storage"
mount -o bind $STORAGE $ENGINCS_OS/root/storage

echo "Sleeping for 10s....."
# To sleep for .5 seconds: 
sleep 10s
#mount - commented out for abuild to run properly
echo "unmounting, please remount for abuild to run properly"
umount $ENGINCS_OS/dev
umount $ENGINCS_OS/proc
umount $ENGINCS_OS/sys
#mount
