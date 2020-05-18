#!/bin/sh

ROOT=$(dirname $(greadlink -f $0))
HAXE_MANAGER_ROOT=$(greadlink -f "$ROOT/../..")

cd $ROOT

npm install

sed 's,/opt/haxe,'"$HAXE_MANAGER_ROOT"',' hxfzf.sh > ../../bin/hxfzf
sed -i 's,/opt/haxe,'"$HAXE_MANAGER_ROOT"',' classpath.hxml
chmod +x ../../bin/hxfzf

cd -
