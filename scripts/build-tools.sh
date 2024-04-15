#!/bin/sh

ROOT=$(dirname $(readlink -f $0))/..
BUILD_OS="linux64"
if [[ "$OSTYPE" == "darwin"* ]]; then
	BUILD_OS="mac"
fi

VERSION="${BUILD_OS}_569e52e"
HAXE_STD_PATH=$ROOT/build/$VERSION/std/ $ROOT/build/$VERSION/haxe --cwd $ROOT build-select.hxml
HAXE_STD_PATH=$ROOT/build/$VERSION/std/ $ROOT/build/$VERSION/haxe --cwd $ROOT build-download.hxml
