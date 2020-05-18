#!/bin/sh

ROOT=$(dirname $(greadlink -f $0))
HAXE_MANAGER_ROOT=$(greadlink -f "$ROOT/../..")

cd $ROOT

sed 's,"/opt/haxe","'"$HAXE_MANAGER_ROOT"'",' hx-upgrade.sh > ../../bin/hx-upgrade
chmod +x ../../bin/hx-upgrade

cd -
