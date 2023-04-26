#!/bin/sh

ROOT=$(dirname $(readlink -f $0))
HAXE_MANAGER_ROOT=$(readlink -f "$ROOT/../..")

cd $ROOT

sed 's,"/opt/haxe","'"$HAXE_MANAGER_ROOT"'",' current-haxe.sh > ../../bin/current-haxe
chmod +x ../../bin/current-haxe

echo "Successfully installed command current-haxe"
cd - > /dev/null
