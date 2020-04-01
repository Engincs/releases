echo "Setting up $PATH and links inside chroot"

#Notice that /tools/bin comes last in the PATH. 
#This means that a temporary tool will no longer be used once its final version is installed. 
#This occurs when the shell does not “remember” the locations of executed binaries—for this reason, 
#hashing is switched off by passing the +h option to bash. 

# External to chroot
chroot /root/engincs-os-chroot/ bash --login +h
#export PATH=$PATH:/root/x-tools/x86_64-unknown-linux-gnu/bin

for dir in 'ls ~/x-tools'; do
PATH=$PATH:~/x-tools/$dir/bin:
done
export PATH

# OPTION 1
# Library path can be defined in 
# vi /etc/ld.so.conf 

# OPTION 2
# To set it temporarily, use the LD_LIBRARY_PATH environment variable on the command line. 
# If you want to keep the changes permanent, then add this line in the shell initialization file /etc/profile (global) or ~/.profile (user specific).
# export LD_LIBRARY_PATH=/root/x-tools/x86_64-unknown-linux-gnu/x86_64-unknown-linux-gnu/sysroot/lib

# OPTION 3
# After creating your shared library, you need to install it. 
# You can either move it into any of the standard directories mentioned above, and run the ldconfig command.
# Alternatively, run the following command to create symbolic links from the soname to the filename:
# ldconfig -n /root/x-tools/x86_64-unknown-linux-gnu/x86_64-unknown-linux-gnu/sysroot/lib

# By default, ldconfig reads the content of /etc/ld.so.conf, creates the appropriate symbolic links in the dynamic link directories, 
# and then writes a cache to /etc/ld.so.cache which is then easily used by other programs.
# ldconfig shows files and directories it works with
# ldconfig -v 

echo "Launching apk update...."
apk update

echo "Creating virtual package for glibc, glibc-dev, glibc-utils ...if required"
#apk add -t glibc
#apk add -t glibc-dev
#apk add -t glibc-utils

#echo "Touch musl missing library files!"
