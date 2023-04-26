#!/bin/sh

ROOT=$(dirname $(readlink -f $0))

cd $ROOT

cp rofi-haxe.sh ../../bin/rofi-haxe
chmod +x ../../bin/rofi-haxe

echo "Successfully installed command rofi-haxe"
cd - > /dev/null
