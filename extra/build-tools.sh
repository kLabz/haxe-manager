#!/bin/bash

ROOT=$(dirname $(readlink -f $0))/..
BUILD_OS="linux64"
if [[ "$OSTYPE" == "darwin"* ]]; then
	BUILD_OS="mac"
else
	ARCH=$(uname -m)
	if [[ "$ARCH" == "arm" ]] || [[ "$ARCH" == "aarch64" ]]; then
		BUILD_OS="linux-arm64"
	fi
fi

VERSION="${BUILD_OS}_569e52e"
HAXE_STD_PATH=$ROOT/build/$VERSION/std/ $ROOT/build/$VERSION/haxe --cwd $ROOT build.hxml
