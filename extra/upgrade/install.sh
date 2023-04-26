#!/bin/sh

ROOT=$(dirname $(readlink -f $0))
HAXE_MANAGER_ROOT=$(readlink -f "$ROOT/../..")

cd $ROOT

sed 's,"/opt/haxe","'"$HAXE_MANAGER_ROOT"'",' hx-upgrade.sh > ../../bin/hx-upgrade
chmod +x ../../bin/hx-upgrade

echo "Successfully installed command hx-upgrade"
cd - > /dev/null
