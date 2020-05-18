#!/bin/sh

ROOT=$(dirname $(greadlink -f $0))

cd $ROOT

cp rofi-haxe.sh ../../bin/rofi-haxe
chmod +x ../../bin/rofi-haxe

cd -
