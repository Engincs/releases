#!/bin/sh

set -e
echo "Launching apk update...."
apk update

echo "Creating virtual package for musl, musl-dev, musl-utils ..."
#apk add -t musl
#apk add -t musl-dev
#apk add -t musl-utils

#echo "Touch musl missing library files!"
