#!/bin/sh

ROOT=$(dirname $(readlink -f $0))
HAXE_MANAGER_ROOT=$(readlink -f "$ROOT/../..")

cd $ROOT

sed 's,/opt/haxe,'"$HAXE_MANAGER_ROOT"',' watch-haxe.sh > ../../bin/watch-haxe
chmod +x ../../bin/watch-haxe

cd -
