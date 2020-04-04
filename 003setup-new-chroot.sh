#!/bin/sh
set -e
# Runme on U(x)buntu 19.10

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

echo "umount dev/proc/sys"
umount /root/engincs-os-chroot/dev
umount /root/engincs-os-chroot/sys
umount /root/engincs-os-chroot/proc

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
./apk -X http://dl-cdn.alpinelinux.org/alpine/edge/main/ -U --allow-untrusted --arch $TARGET_ARCH --root /root/new-engincs-os-chroot/ --initdb add busybox-static apk-tools-static alpine-keys linux-headers

echo "Binding and mounting dev, proc and sys"
mkdir /root/new-engincs-os-chroot/sys
mount /dev/ /root/new-engincs-os-chroot/dev/ --bind
mount -o remount,ro,bind /root/new-engincs-os-chroot/dev
mount -t proc none /root/new-engincs-os-chroot/proc 
mount -o bind /sys /root/new-engincs-os-chroot/sys

echo "Creating root directory"
mkdir -p /root/new-engincs-os-chroot/root

echo "creating resolv.conf"
cp /etc/resolv.conf /root/new-engincs-os-chroot/etc/ 
#echo -e 'nameserver 8.8.8.8\nnameserver 2620:0:ccc::2' > /root/new-engincs-os-chroot/etc/resolv.conf
printf 'nameserver 8.8.8.8\nnameserver 2620:0:ccc::2' > /root/new-engincs-os-chroot/etc/resolv.conf

echo "creating repositories folder"
mkdir -p /root/new-engincs-os-chroot/etc/apk 
printf 'http://dl-cdn.alpinelinux.org/alpine/edge/main/\nhttp://dl-cdn.alpinelinux.org/alpine/edge/community/\nhttp://dl-cdn.alpinelinux.org/alpine/edge/testing/' > /root/new-engincs-os-chroot/etc/apk/repositories

echo "Chroot and generate busybox symbolic links"
#chroot /root/engincs-os-chroot/ busybox.static sh
chroot /root/new-engincs-os-chroot/ /bin/busybox.static --install -s /bin
#exit
echo "Exited chroot"

echo "moving apk required for abuild"
mv /root/new-engincs-os-chroot/sbin/apk.static /root/engincs-os-chroot/sbin/apk

echo "Copy recursively the toolchain to the previous chroot directory"
# Run recursive copy command 
# Recursive verbose copy cp -avr source /target/
cp -avr /root/x-tools/ /root/new-engincs-os-chroot/root/

echo "Copy the abuild files to new chroot"
cd /root/engincs-os-chroot/root/abuild
cp abuild abuild-fetch abuild-gzsplit abuild-keygen abuild-rmtemp abuild-sign abuild-sudo abuild-tar /root/new-engincs-os-chroot/usr/bin
cp abump apkbuild-cpan apkbuild-gem-resolver /root/new-engincs-os-chroot/usr/bin
cp apkbuild-pypi apkgrel newapkbuild bootchartd buildlab checkapk newapkbuild /root/new-engincs-os-chroot/usr/bin

cp abuild.conf /root/new-engincs-os-chroot/etc/

mkdir /root/new-engincs-os-chroot/usr/share/abuild
cp sample.confd sample.initd functions.sh sample.APKBUILD sample.post-install sample.pre-install config.sub /root/new-engincs-os-chroot/usr/share/abuild

cp /root/engincs-os-chroot/root/abuild/tests/testrepo/pkg1/APKBUILD /root/new-engincs-os-chroot/usr/share/abuild/APKBUILD-SAMPLE
