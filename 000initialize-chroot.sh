#!/bin/sh

TARGET_ARCH=$1

if [ -z "$TARGET_ARCH" ]; then
 printf 'Please enter target architecture\n\n'
 print  'x86 Based\n'
 print   '-- x86 - 32 bit x86 (ia32)\n'
 print   '-- x86_64 - 64 bit x86 (amd64)\n\n'
 print   'ARM Based\n'
 print   '-- armhf - 32 bit ARM (hard-float ABI)\n'
 print   '-- aarch64 - 64 bit ARM\n\n'
 print   'PowerPC Based\n'
 print   '-- ppc64le - 64 bit PowerPC (little-endian)\n\n'
 print   'IBM System Z Based\n'
 print   '-- s390x\n'
 return 1
fi

# Getting read for Glibc port of Alpine - Test script only
cd /root/

echo "Getting apktools static version 64-bit"
export APKTOOLSVERSION=2.10.5-r0
wget http://dl-cdn.alpinelinux.org/alpine/edge/main/x86_64/apk-tools-static-$APKTOOLSVERSION.apk

echo "Untar apktools static version 64-bit"
tar -xzf apk-tools-static-*.apk
cp sbin/apk.static apk
rm -rf apk-tools-static-*.apk
rm -rf sbin/

echo "Creating chroot with busybox, alpine-keys and apk-tools"
#./apk -X http://dl-cdn.alpinelinux.org/alpine/edge/main/ -U --allow-untrusted --root /root/engincs-os-chroot/ --initdb add busybox-static apk-tools-static alpine-keys
./apk -X http://dl-cdn.alpinelinux.org/alpine/edge/main/ -U --allow-untrusted --arch $TARGET_ARCH --root /root/engincs-os-chroot/ --initdb add busybox-static apk-tools-static alpine-keys

echo "Binding and mounting dev, proc and sys"
mount /dev/ /root/engincs-os-chroot/dev/ --bind
mount -o remount,ro,bind /root/engincs-os-chroot/dev
mount -t proc none /root/engincs-os-chroot/proc 

mkdir /root/engincs-os-chroot/sys
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
#mount - commented out for abuild run
#umount /root/engincs-os-chroot/dev
#umount /root/engincs-os-chroot/proc
#umount /root/engincs-os-chroot/sys
#mount
