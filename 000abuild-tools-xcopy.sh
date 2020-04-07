#!/bin/sh
set -e
# Runme on U(x)buntu 19.10

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
