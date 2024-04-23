#!/bin/bash

ROOT=$(dirname $(readlink -f $0))
HAXE_MANAGER_ROOT=$(readlink -f "$ROOT/../..")

cd $ROOT

sed 's,"/opt/haxe","'"$HAXE_MANAGER_ROOT"'",' hx-mklocal.sh > ../../bin/hx-mklocal
chmod +x ../../bin/hx-mklocal

echo "Successfully installed command hx-mklocal"
cd - > /dev/null
