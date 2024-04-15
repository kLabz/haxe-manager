#!/bin/bash

ROOT=$(dirname $(readlink -f $0))
HAXE_MANAGER_ROOT=$(readlink -f "$ROOT/../..")

cd $ROOT

sed 's,"/opt/haxe","'"$HAXE_MANAGER_ROOT"'",' list-haxe-versions.sh > ../../bin/list-haxe-versions
chmod +x ../../bin/list-haxe-versions

echo "Successfully installed command list-haxe-versions"
cd - > /dev/null
