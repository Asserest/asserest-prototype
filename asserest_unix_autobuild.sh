#!/bin/bash

#    _     __      __      __      _     __    ________   ____     __      __      
#  /' \  /'_ `\  /'_ `\  /'_ `\  /' \  /'__`\ /\_____  \ /'___\  /'_ `\  /'_ `\    
# /\_, \/\ \L\ \/\ \L\ \/\ \L\ \/\_, \/\ \/\ \\/___//'/'/\ \__/ /\ \L\ \/\ \L\ \   
# \/_/\ \ \___, \/_> _ <\ \___, \/_/\ \ \ \ \ \   /' /' \ \  _``\ \___, \ \___, \  
#    \ \ \/__,/\ \/\ \L\ \/__,/\ \ \ \ \ \ \_\ \/' /'    \ \ \L\ \/__,/\ \/__,/\ \ 
#     \ \_\   \ \_\ \____/    \ \_\ \ \_\ \____/\_/       \ \____/    \ \_\   \ \_\
#      \/_/    \/_/\/___/      \/_/  \/_/\/___/\//         \/___/      \/_/    \/_/
#
#
#
#  ________  ___  ________  _______           ________  ___  ___  ________  ___       __   _______   ________     
# |\   __  \|\  \|\   ____\|\  ___ \         |\   ____\|\  \|\  \|\   __  \|\  \     |\  \|\  ___ \ |\   __  \    
# \ \  \|\  \ \  \ \  \___|\ \   __/|        \ \  \___|\ \  \\\  \ \  \|\  \ \  \    \ \  \ \   __/|\ \  \|\  \   
#  \ \   _  _\ \  \ \  \    \ \  \_|/__       \ \_____  \ \   __  \ \  \\\  \ \  \  __\ \  \ \  \_|/_\ \   _  _\  
#   \ \  \\  \\ \  \ \  \____\ \  \_|\ \       \|____|\  \ \  \ \  \ \  \\\  \ \  \|\__\_\  \ \  \_|\ \ \  \\  \| 
#    \ \__\\ _\\ \__\ \_______\ \_______\        ____\_\  \ \__\ \__\ \_______\ \____________\ \_______\ \__\\ _\ 
#     \|__|\|__|\|__|\|_______|\|_______|       |\_________\|__|\|__|\|_______|\|____________|\|_______|\|__|\|__|
#                                               \|_________|                                                      
                                                                                 

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
unset -f dart_init
unset $DART_VERSION
unset $ASSEREST_BRANCHES
unset $OGPWD
