#!/bin/sh

ROOT=$(dirname $(readlink -f $0))
HAXE_MANAGER_ROOT=$(readlink -f "$ROOT/../..")

cd $ROOT

npm install

sed 's,"/opt/haxe","'"$HAXE_MANAGER_ROOT"'",' ++haxe.sh > ../../bin/++haxe
chmod +x ./parse.js
chmod +x ../../bin/++haxe

cd -
