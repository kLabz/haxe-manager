#!/bin/sh

HAXE_MANAGER_ROOT="/opt/haxe"
HAXE_DEV_PATH=$1
RELEASE_NAME=$2

if [ -z "$HAXE_DEV_PATH" ]; then
	echo "Missing argument: path to haxe repository"
	exit 1
fi

if [ ! -d "$HAXE_DEV_PATH" ]; then
	echo "Cannot find path to haxe repository"
	exit 1
fi

if [ -z "$RELEASE_NAME" ]; then
	echo "Missing argument: release name (for example '20190101133742_abc123')"
	exit 1
fi

RELEASE_NAME="haxe_${RELEASE_NAME}_local"

if [ -d "$HAXE_MANAGER_ROOT/releases/$RELEASE_NAME" ]; then
	exit 0
fi

mkdir -p $HAXE_MANAGER_ROOT/releases/$RELEASE_NAME
cd $HAXE_MANAGER_ROOT/releases/$RELEASE_NAME

cp -R $HAXE_DEV_PATH/std .
cp $HAXE_DEV_PATH/haxe .
cp $HAXE_DEV_PATH/haxelib .
cd -
