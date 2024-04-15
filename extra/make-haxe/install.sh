#!/bin/bash

ROOT=$(dirname $(readlink -f $0))
HAXE_MANAGER_ROOT=$(readlink -f "$ROOT/../..")

cd $ROOT

sed 's,"/opt/haxe","'"$HAXE_MANAGER_ROOT"'",' make-haxe.sh > ../../bin/make-haxe
chmod +x ../../bin/make-haxe

mkdir -p "$HAXE_MANAGER_ROOT/builds"

echo "Successfully installed command make-haxe"
cd - > /dev/null
