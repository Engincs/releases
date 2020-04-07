echo "Setting up $PATH and links inside chroot"
touch /etc/ld.so.conf
ldconfig
printf 'nameserver 8.8.8.8\nnameserver 2620:0:ccc::2' > $ENGINCS_OS/etc/resolv.conf

# Notice that /root/engincs-os-chroot/root/x-tools/x86_64-unknown-linux/bin comes last in the PATH. 
# This means that a temporary tool will no longer be used once its final version is installed. 
# This occurs when the shell does not “remember” the locations of executed binaries—
# for this reason, hashing is switched off by passing the +h option to bash. 

# External to chroot
# chroot /root/engincs-os/ bash --login +h

# export PATH=$PATH:/root/x-tools/x86_64-linux-gnu/bin
# export PATH=$PATH:/root/x-tools/x86_64-linux-gnu/x86_64-linux-gnu/sysroot/sbin

# Internal to chroot
# for dir in 'ls ~/x-tools'; do
# PATH=$PATH:~/x-tools/$dir/bin:
# done
# export PATH

# OPTION 1
# Library path can be defined in 
# vi /etc/ld.so.conf 
# /lib
# /lib64
# /usr/lib
# /usr/lib64
# /root/x-tools/x86_64-linux-gnu/x86_64-linux-gnu/sysroot/lib
# /root/x-tools/x86_64-linux-gnu/x86_64-inux-gnu/sysroot/usr/lib
# /root/x-tools/x86_64-linux-gnu/lib

# OPTION 2
# To set it temporarily, use the LD_LIBRARY_PATH environment variable on the command line. 
# If you want to keep the changes permanent, then add this line in the shell initialization file /etc/profile (global) or ~/.profile (user specific).
# export LD_LIBRARY_PATH=/root/x-tools/x86_64-linux-gnu/x86_64-linux-gnu/sysroot/lib

# OPTION 3
# After creating your shared library, you need to install it. 
# You can either move it into any of the standard directories mentioned above, and run the ldconfig command.
# Alternatively, run the following command to create symbolic links from the soname to the filename:
# ldconfig -n /root/x-tools/x86_64-linux-gnu/x86_64-linux-gnu/sysroot/lib

# By default, ldconfig reads the content of /etc/ld.so.conf, creates the appropriate symbolic links in the dynamic link directories, 
# and then writes a cache to /etc/ld.so.cache which is then easily used by other programs.
# ldconfig shows files and directories it works with
# ldconfig -v 

echo "Launching apk update...."
apk update

echo "Creating required files...."
# linux-vdso.so.1 (0x00007ffc2b33a000)
# libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fd603d17000)
# /lib64/ld-linux-x86-64.so.2 (0x00007fd603f8e000)

# copy from sysroot/lib of libtools to /lib, /lib/x86_64-linux-gnu/ and /lib64
# mkdir /lib/x86_64-linux-gnu/
# cp libc.so.6 libc-2.31.so /lib/x86_64-linux-gnu/
# mkdir /lib64/
# cp ld-linux-x86-64.so.2 ld-2.31.so /lib64/

echo "Creating virtual package for glibc, glibc-dev, glibc-utils ...if required"
apk add -t glibc
# apk add -t glibc-dev
# apk add -t glibc-utils

echo "Touch (append) world db for include library files! Remember to remove any blank spaces before appending at the last"
cp /lib/apk/db/installed /lib/apk/db/installed-backup
# printf 'p:so:libc.so.6=6\nF:lib/x86_64-linux-gnu\nR:libc.so.6' >> /lib/apk/db/installed
printf 'p:so:libc.so.6=6 so:libcrypt.so.1=1 so:libdl.so.2=2 so:libm.so.6=6 so:libpthread.so.0=0 so:libutil.so.1=1 so:librt.so.1=1\nF:lib/x86_64-linux-gnu\nR:libc.so.6\nR:libcrypt.so.1\nR:libdl.so.2\nR:libm.so.6\nR:libpthread.so.0\nR:libutil.so.1\nR:librt.so.1' >> /lib/apk/db/installed

echo "Please make sure to run abuild-keygen with a and i options\n"
# abuild-keygen -a -i 
# which created keys and wrote in the host /etc/abuild.conf file automatically
echo "============================================================\n"
echo "Edit /usr/share/abuild/functions.sh to replace musl with gnu"
echo "============================================================\n"
echo "Create links in /bin folder for gcc"
