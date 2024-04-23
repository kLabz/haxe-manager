#!/bin/bash

HAXE_MANAGER_ROOT="/opt/haxe"

errFile=$(mktemp)

haxe $@ 2> "$errFile"
errCode="$?"

cat "$errFile" | "$HAXE_MANAGER_ROOT/extra/++haxe/parse.js"
rm "$errFile"

exit "$errCode"
