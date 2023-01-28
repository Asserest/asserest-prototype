#!/bin/bash

# This is a shell script for instant install asserest in Linux terminal.
#
# You will get a binary on your home directory (~/) if no error encountered
# during execution.

OGPATH = $PATH
DART_VERSION = "2.19.0"
ASSEREST_BRANCHES = "preview"

dart_init () {
    # Check does Dart SDK installed already
    which dart > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        return 0
    fi

    # Install Dart SDK temproary
    DART_ZIP = "https://storage.googleapis.com/dart-archive/channels/stable/release/${DART_VERSION}/sdk/dartsdk-linux-x64-release.zip"
    wget -O /tmp/dart.zip $DART_ZIP
    unzip /tmp/dart.zip /tmp
    rm /tmp/dart.zip
    PATH = $PATH:/tmp/dart-sdk/bin
    unset $DART_ZIP

    return 1
}

OGPWD = pwd

# Ensure in home directory
cd ~

# Initalize
dart_init
TMP_DART = $?

# Get source code and compile
git clone --branch $ASSEREST_BRANCHES https://github.com/rk0cc/asserest.git
cd asserest
dart pub get
dart compile exe bin/asserest.dart --output="./out/asserest.bin"
mv out/asserest.bin ~/asserest.bin

# Post install cleanup
cd ~
rm -rf asserest
mv asserest.bin asserest

if [ $TMP_DART -eq 1 ]; then
    PATH = $OGPATH
    rm -rf /tmp/dart-sdk
fi

echo "Asserest has been installed into your home directory."
cd $OGPWD
unset $DART_VERSION
unset $ASSEREST_BRANCHES
unset $OGPWD
