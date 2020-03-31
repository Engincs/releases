echo "Setting up $PATH and links inside chroot"

for dir in 'ls ~/x-tools'; do
PATH=~/x-tools/$dir/bin:$PATH
done
export PATH


echo "Launching apk update...."
apk update

echo "Creating virtual package for glibc, glibc-dev, glibc-utils ...if required"
#apk add -t glibc
#apk add -t glibc-dev
#apk add -t glibc-utils

#echo "Touch musl missing library files!"
