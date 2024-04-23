#!/bin/bash

HAXE_MANAGER_ROOT="/opt/haxe"
# TODO: make sure we're on haxe repository

status=$(git status --porcelain --ignore-submodules | grep -v "^??")
if [ -z "$status" ] || [ "$1" = "--force-cache" ]; then
	ref=$(git rev-parse --short HEAD)
	cacheDir="$HAXE_MANAGER_ROOT/builds/$ref"

	if [ -d "$cacheDir" ]; then
		echo "Use haxe and haxelib from cache for ref $ref"
		cp -f "$cacheDir/haxe" .
		cp -f "$cacheDir/haxelib" .
	else
		ADD_REVISION=1 make haxe && \
		mkdir -p "$cacheDir" && \
		cp ./haxe "$cacheDir" && \
		cp ./haxelib "$cacheDir"

		if [ ! -z "$status" ]; then
			git diff --patch HEAD > "$cacheDir/status.patch"
		fi
	fi
else
	ADD_REVISION=1 make haxe
fi
