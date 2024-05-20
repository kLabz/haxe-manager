#!/bin/bash

ROOT=$(dirname $(readlink -f $0))/..
BUILD_OS="linux64"
if [[ "$OSTYPE" == "darwin"* ]]; then
	BUILD_OS="mac"
fi

HAXE_VER=$(cat $ROOT/build/.current)
VERSION="${BUILD_OS}_${HAXE_VER}"

HAXE_STD_PATH=$ROOT/build/$VERSION/std/ $ROOT/build/$VERSION/haxe --cwd $ROOT build.hxml --hxb build/hx.hxb
