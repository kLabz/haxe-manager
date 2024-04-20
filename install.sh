#!/bin/bash

ROOT=$(dirname $(readlink -f $0))
HAXE_VER="569e52e"

mkdir -p "$ROOT/releases"
mkdir -p "$ROOT/versions"
mkdir -p "$ROOT/bin"

# Install base tools
cp extra/hx bin/
cp extra/hx-download bin/
cp extra/hx-select bin/

# Install fzf if needed
# TODO remove this
if ! [ -x "$(command -v fzf)" ]; then
	cd "$ROOT/bin"

	BUILD_OS="linux"
	if [[ "$OSTYPE" == "darwin"* ]]; then
		BUILD_OS="darwin"
	fi

	wget "https://github.com/junegunn/fzf-bin/releases/download/0.17.4/fzf-0.17.4-${BUILD_OS}_amd64.tgz"
	tar -xf "fzf-0.17.4-${BUILD_OS}_amd64.tgz"
	rm "fzf-0.17.4-${BUILD_OS}_amd64.tgz"
	cd - > /dev/null
fi

# Setup included Haxe version
if ! [ -e "versions/5.0.0-alpha.1+$HAXE_VER" ]; then
	BUILD_OS="linux64"
	if [[ "$OSTYPE" == "darwin"* ]]; then
		BUILD_OS="mac"
	fi

	ln -s "$ROOT/build/${BUILD_OS}_$HAXE_VER" "versions/5.0.0-alpha.1+$HAXE_VER"
fi
if ! [ -e "current" ]; then
	ln -s "$ROOT/build/${BUILD_OS}_${HAXE_VER}" "current"
fi

# Expose haxe command
if ! [ -e "bin/haxe" ]; then
	ln -s ../current/haxe bin/haxe
fi

# Expose haxelib command
if ! [ -e "bin/haxelib" ]; then
	ln -s ../current/haxelib bin/haxelib
fi

# Prebuild tools
HAXE_STD_PATH="$ROOT/build/${BUILD_OS}_${HAXE_VER}/std/" "$ROOT/build/${BUILD_OS}_${HAXE_VER}/haxe" --cwd "$ROOT" build-select.hxml
HAXE_STD_PATH="$ROOT/build/${BUILD_OS}_${HAXE_VER}/std/" "$ROOT/build/${BUILD_OS}_${HAXE_VER}/haxe" --cwd "$ROOT" build-download.hxml

echo "Please add $ROOT/bin to your PATH"
echo "Please set HAXE_STD_PATH to $ROOT/current/std"
