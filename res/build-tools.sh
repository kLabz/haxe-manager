#!/bin/bash

ROOT=$(dirname $(readlink -f $0))/..
BUILD_OS="linux64"
if [[ "$OSTYPE" == "darwin"* ]]; then
	BUILD_OS="mac"
fi

HAXE_VER=$(cat $ROOT/res/.current)
VERSION="${BUILD_OS}_${HAXE_VER}"

HAXE_STD_PATH=$ROOT/res/$VERSION/std/ $ROOT/res/$VERSION/haxe --cwd $ROOT build.hxml --hxb res/hx.hxb
