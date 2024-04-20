#!/bin/sh

ROOT=$(dirname $(readlink -f $0))
HAXE_MANAGER_ROOT=$(readlink -f "$ROOT/../..")

cd $ROOT

sed 's,"/opt/haxe","'"$HAXE_MANAGER_ROOT"'",' nightlies.sh > ../../bin/hx-nightlies
chmod +x ../../bin/hx-nightlies

echo "Successfully installed command hx-nightlies"
cd - > /dev/null
