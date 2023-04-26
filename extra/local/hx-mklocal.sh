#!/bin/sh

HAXE_MANAGER_ROOT="/opt/haxe"
HAXE_DEV_PATH=$1
RELEASE_NAME=$2

if [ -z "$HAXE_DEV_PATH" ]; then
	echo "Missing argument: path to haxe repository"
	exit 1
fi

HAXE_DEV_PATH=$(realpath "$HAXE_DEV_PATH")
if [ ! -d "$HAXE_DEV_PATH" ]; then
	echo "Cannot find path to haxe repository"
	exit 1
fi

if [ -z "$RELEASE_NAME" ]; then
	echo "Missing argument: release name (for example '20190101133742_abc123')"
	exit 1
fi

RELEASE_PATH="haxe_${RELEASE_NAME}_local"

if [ -d "$HAXE_MANAGER_ROOT/releases/$RELEASE_PATH" ]; then
	echo "$RELEASE_NAME already exists; overwriting..."
	rm -rf "$HAXE_MANAGER_ROOT/releases/$RELEASE_PATH"
fi

mkdir -p "$HAXE_MANAGER_ROOT/releases/$RELEASE_PATH"
cd "$HAXE_MANAGER_ROOT/releases/$RELEASE_PATH"
cp -R "$HAXE_DEV_PATH/std" .
cp "$HAXE_DEV_PATH/haxe" .
cp "$HAXE_DEV_PATH/haxelib" .

unlink "$HAXE_MANAGER_ROOT/versions/$RELEASE_NAME" 2> /dev/null
ln -s "$HAXE_MANAGER_ROOT/releases/$RELEASE_PATH" "$HAXE_MANAGER_ROOT/versions/$RELEASE_NAME"

cd - > /dev/null
