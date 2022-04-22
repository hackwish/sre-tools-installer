#!/bin/bash
##

echo ""
echo "DevOps-SRE Tools installer"
echo ""
echo "Before to start, let's detect your OS..."
echo ""

OS=`uname`

if [[ $OS == "Darwin" ]]; then
    echo $OS
    echo ""
    read -p "...Press Enter to start..."
    echo ""
    function mac () {
        source install_mac.sh
    }
    mac
elif [[ $OS == "Linux" ]]; then
    echo $OS
    echo ""
    read -p "...Press Enter to start..."
    echo ""
    function linux () {
        source install_linux.sh
    }
    linux
else
    echo 'Uhmm, OS not detected. Bye!'
    exit0;
fi