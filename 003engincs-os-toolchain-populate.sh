#!/bin/sh
set -e

# Runme on U(x)buntu 19.10

echo "Copy recursively the toolchain to the engincs os directory"
# Run recursive copy command 
# Recursive verbose copy cp -avr source /target/
cp -avr /root/storage/x86-64-core-i7--glibc--bleeding-edge-2020.02-2/x86_64-buildroot-linux-gnu/sysroot/* /root/engincs-os
cp -avr /root/storage/x86-64-core-i7--glibc--bleeding-edge-2020.02-2/bin/* /root/engincs-os/bin

echo "Copy the abuild and tools files to engincs os chroot"
cd /root/storage/abuild
cp abuild abuild-fetch abuild-gzsplit abuild-keygen abuild-rmtemp abuild-sign abuild-sudo abuild-tar /root/engincs-os/usr/bin
cp abump apkbuild-cpan apkbuild-gem-resolver /root/engincs-os/usr/bin
cp apkbuild-pypi apkgrel newapkbuild bootchartd buildlab checkapk /root/engincs-os/usr/bin

cp abuild.conf /root/engincs-os/etc/

mkdir /root/engincs-os/usr/share/abuild
cp sample.confd sample.initd functions.sh sample.APKBUILD sample.post-install sample.pre-install config.sub /root/engincs-os/usr/share/abuild
cp tests/testrepo/pkg1/APKBUILD /root/engincs-os/usr/share/abuild/APKBUILD-SAMPLE

echo "copying rest of tools"
cd /root/storage
rm -rf /root/engincs-os/bin/patch
cp patch scanelf /root/engincs-os/bin
cp make /root/engincs-os/bin

cd /root/storage/attr-2.4.48
cp attr getfattr setfattr /root/engincs-os/bin

cd /root/storage/openssl-1.1.1f/apps
cp openssl /root/engincs-os/bin

cd /root/storage/tar-1.32/src
rm -rf /root/engincs-os/bin/tar
cp tar /root/engincs-os/bin

cd /root/storage/wget-1.20.3/src
rm -rf /root/engincs-os/bin/wget
cp wget /root/engincs-os/bin

cd /root/
mkdir /root/engincs-os/etc/ssl
cp -avr /root/abuild-tools/etc/ssl/certs /root/engincs-os/etc/ssl
cp /root/abuild-tools/etc/ssl/cert.pem /root/engincs-os/etc/ssl/cert.pem

# Crosstool-ng is not feasible due inaccurate ldd pointers
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
# Cannot find -lz error, include ZLIB_LIB=/lib, ZLIB_INCLUDE=/usr/include for perl in APKBUILD however not all packages provide such facility

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
