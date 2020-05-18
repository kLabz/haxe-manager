#!/bin/sh

ROOT=$(dirname $(greadlink -f $0))
HAXE_MANAGER_ROOT=$(greadlink -f "$ROOT/../..")

cd $ROOT

sed 's,"/opt/haxe","'"$HAXE_MANAGER_ROOT"'",' list-haxe-versions.sh > ../../bin/list-haxe-versions
chmod +x ../../bin/list-haxe-versions

cd -
