#!/bin/sh

ROOT=$(dirname $(readlink -f $0))
HAXE_MANAGER_ROOT=$(readlink -f "$ROOT/../..")

cd $ROOT

sed 's,/opt/haxe,'"$HAXE_MANAGER_ROOT"',' hxfzf.sh > ../../bin/hxfzf
sed -i'' -e 's,/opt/haxe,'"$HAXE_MANAGER_ROOT"',' classpath.hxml
chmod +x ../../bin/hxfzf

echo "Successfully installed command hxfzf"
cd - > /dev/null
