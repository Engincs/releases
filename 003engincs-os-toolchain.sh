#!/bin/sh
set -e

# Runme on U(x)buntu 19.10
apt -y install build-essential autoconf bison flex texinfo help2man gawk libtool libncurses5-dev python3-dev python3-distutils git gettext libtool-bin libtool-doc 
apt -y install ncurses-dev bison texinfo flex autoconf automake libtool patch curl cvs build-essential subversion gawk gperf libncurses5-dev libexpat1-dev
apt-get install zliblg-dev
apt-get install libssl-dev

echo "Copy recursively the toolchain to the engincs os directory"
# Run recursive copy command 
# Recursive verbose copy cp -avr source /target/
cp -avr /root/x-tools/ /root/new-engincs-os-chroot/root/

echo "Copy the abuild and tools files to engincs os chroot"
mkdir /root/new-engincs-os-chroot/usr/bin
cd /root/engincs-os-chroot/root/abuild
cp abuild abuild-fetch abuild-gzsplit abuild-keygen abuild-rmtemp abuild-sign abuild-sudo abuild-tar /root/new-engincs-os-chroot/usr/bin
cp abump apkbuild-cpan apkbuild-gem-resolver /root/new-engincs-os-chroot/usr/bin
cp apkbuild-pypi apkgrel newapkbuild bootchartd buildlab checkapk /root/new-engincs-os-chroot/usr/bin

cp abuild.conf /root/new-engincs-os-chroot/etc/

mkdir /root/new-engincs-os-chroot/usr/share/abuild
cp sample.confd sample.initd functions.sh sample.APKBUILD sample.post-install sample.pre-install config.sub /root/new-engincs-os-chroot/usr/share/abuild

cp /root/engincs-os-chroot/root/abuild/tests/testrepo/pkg1/APKBUILD /root/new-engincs-os-chroot/usr/share/abuild/APKBUILD-SAMPLE


# Crosstool-not not feasible due inaccurate ldd pointers
# GCC and GNU ld are configured against a common sysroot --sysroot=path. 
# This means that where ld scripts refer to their subordinate libraries using an absolute path, the path is still relative to sysroot.
# LD_LIBRARY_PATH, LIBRARY_PATH, LD_PRELOAD, /etc/ld.conf.so will not have any effect. Not even pkgconfig
# Refer to https://answers.ros.org/question/55150/ld-searches-in-wrong-folder-for-libraries-when-cross-compiling/
# Linking manually or Replacing the whole lib folder has not effect
# No mechanism to disable/chain sysroot for the original toolchain

# Below are artifacts for ld -lcursesw --verbose 
# /root/x-tools/x86_64-linux-gnu/bin/ld.bfd: mode elf_x86_64
# attempt to open /root/x-tools/x86_64-linux-gnu/bin/../x86_64-linux-gnu/sysroot/root/x-tools/x86_64-linux-gnu/x86_64-linux-gnu/lib64/libcursesw.so failed
# attempt to open /root/x-tools/x86_64-linux-gnu/bin/../x86_64-linux-gnu/sysroot/root/x-tools/x86_64-linux-gnu/x86_64-linux-gnu/lib64/libcursesw.a failed
# attempt to open /root/x-tools/x86_64-linux-gnu/bin/../x86_64-linux-gnu/sysroot/usr/local/lib64/libcursesw.so failed
# attempt to open /root/x-tools/x86_64-linux-gnu/bin/../x86_64-linux-gnu/sysroot/usr/local/lib64/libcursesw.a failed
# attempt to open /root/x-tools/x86_64-linux-gnu/bin/../x86_64-linux-gnu/sysroot/lib64/libcursesw.so failed
# attempt to open /root/x-tools/x86_64-linux-gnu/bin/../x86_64-linux-gnu/sysroot/lib64/libcursesw.a failed
# attempt to open /root/x-tools/x86_64-linux-gnu/bin/../x86_64-linux-gnu/sysroot/usr/lib64/libcursesw.so failed
# attempt to open /root/x-tools/x86_64-linux-gnu/bin/../x86_64-linux-gnu/sysroot/usr/lib64/libcursesw.a failed
# attempt to open /root/x-tools/x86_64-linux-gnu/bin/../x86_64-linux-gnu/sysroot/root/x-tools/x86_64-linux-gnu/x86_64-linux-gnu/lib/libcursesw.so failed
# attempt to open /root/x-tools/x86_64-linux-gnu/bin/../x86_64-linux-gnu/sysroot/root/x-tools/x86_64-linux-gnu/x86_64-linux-gnu/lib/libcursesw.a failed
# attempt to open /root/x-tools/x86_64-linux-gnu/bin/../x86_64-linux-gnu/sysroot/usr/local/lib/libcursesw.so failed
# attempt to open /root/x-tools/x86_64-linux-gnu/bin/../x86_64-linux-gnu/sysroot/usr/local/lib/libcursesw.a failed
# attempt to open /root/x-tools/x86_64-linux-gnu/bin/../x86_64-linux-gnu/sysroot/lib/libcursesw.so failed
# attempt to open /root/x-tools/x86_64-linux-gnu/bin/../x86_64-linux-gnu/sysroot/lib/libcursesw.a failed
# attempt to open /root/x-tools/x86_64-linux-gnu/bin/../x86_64-linux-gnu/sysroot/usr/lib/libcursesw.so failed
# attempt to open /root/x-tools/x86_64-linux-gnu/bin/../x86_64-linux-gnu/sysroot/usr/lib/libcursesw.a failed
# Cannot find -lz error, includ ZLIB_LIB=/lib, ZLIB_INCLUDE=/usr/include for perl in APKBUILD however not all packages provide such facility

# cd /root
# git clone https://github.com/crosstool-ng/crosstool-ng
# cd /root/crosstool-ng

# ./bootstrap
# echo "only build it and run from the source directory optional"
# ./configure --enable-local
# echo "only make command and make install not required"
# make
# ./ct-ng help
# ./ct-ng version

# mkdir -v /root/src
# mkdir -v /root/crosstool-ng/src

# ./ct-ng list-samples | grep x86_64
# ./ct-ng show-x86_64-unknown-linux-gnu
# echo "Select x86_64-unknown-linux-gnu and customize"
# ./ct-ng x86_64-unknown-linux-gnu
# ./ct-ng menuconfig
# ./ct-ng build
