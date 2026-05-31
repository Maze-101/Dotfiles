#!/bin/bash

var1='sudo make clean install'
var2='sudo rm config.h'

echo "Building suckless software..."
cd ~/dotfiles/suckless/dwm && $var2 && $var1
cd ../slock && $var2 && $var1
cd ../dwmblocks && sudo rm blocks.h && $var1
cd ../st && sudo rm config.h && $var1

echo "#############################"
echo "########    Done!    ########"
echo "#############################"