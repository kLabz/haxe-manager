#!/bin/sh

HAXE_MANAGER_ROOT="/opt/haxe"

realpath --relative-base=$HAXE_MANAGER_ROOT/versions -s $(greadlink $HAXE_MANAGER_ROOT/bin/haxe) | cut -d "/" -f 1
