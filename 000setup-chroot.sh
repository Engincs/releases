#!/bin/sh

set -e

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
#./apk -X http://dl-cdn.alpinelinux.org/alpine/edge/main/ -U --allow-untrusted --root /root/engincs-os-chroot/ --initdb add busybox-static apk-tools-static alpine-keys
./apk -X http://dl-cdn.alpinelinux.org/alpine/edge/main/ -U --allow-untrusted --arch $TARGET_ARCH --root /root/engincs-os-chroot/ --initdb add busybox-static apk-tools-static alpine-keys linux-headers

echo "Binding and mounting dev, proc and sys"
mkdir /root/engincs-os-chroot/sys
mount /dev/ /root/engincs-os-chroot/dev/ --bind
mount -o remount,ro,bind /root/engincs-os-chroot/dev
mount -t proc none /root/engincs-os-chroot/proc 
mount -o bind /sys /root/engincs-os-chroot/sys

echo "Creating root directory"
mkdir -p /root/engincs-os-chroot/root

echo "creating resolv.conf"
cp /etc/resolv.conf /root/engincs-os-chroot/etc/ 
#echo -e 'nameserver 8.8.8.8\nnameserver 2620:0:ccc::2' > /root/engincs-os-chroot/etc/resolv.conf
printf 'nameserver 8.8.8.8\nnameserver 2620:0:ccc::2' > /root/engincs-os-chroot/etc/resolv.conf


echo "creating repositories folder"
mkdir -p /root/engincs-os-chroot/etc/apk 
printf 'http://dl-cdn.alpinelinux.org/alpine/edge/main/\nhttp://dl-cdn.alpinelinux.org/alpine/edge/community/\nhttp://dl-cdn.alpinelinux.org/alpine/edge/testing/' > /root/engincs-os-chroot/etc/apk/repositories

echo "Chroot and generate busybox symbolic links"
#chroot /root/engincs-os-chroot/ busybox.static sh
chroot /root/engincs-os-chroot/ /bin/busybox.static --install -s /bin
#exit
echo "Exited chroot"

echo "moving apk required for abuild"
mv /root/engincs-os-chroot/sbin/apk.static /root/engincs-os-chroot/sbin/apk

echo "Chroot and run apk update"
#chroot /root/engincs-os-chroot/ /bin/sh -l
#apk update
#exit
echo "Exited chroot"

echo "Unmounting directories"
# To sleep for .5 seconds: 
sleep 10s
#mount - commented out for abuild to run properly
#umount /root/engincs-os-chroot/dev
#umount /root/engincs-os-chroot/proc
#umount /root/engincs-os-chroot/sys
#mount
