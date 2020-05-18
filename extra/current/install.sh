#!/bin/sh

ROOT=$(dirname $(greadlink -f $0))
HAXE_MANAGER_ROOT=$(greadlink -f "$ROOT/../..")

cd $ROOT

sed 's,"/opt/haxe","'"$HAXE_MANAGER_ROOT"'",' current-haxe.sh > ../../bin/current-haxe
chmod +x ../../bin/current-haxe

cd -
