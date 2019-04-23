#!/bin/sh

HAXE_MANAGER_ROOT="/opt/haxe"

find "$HAXE_MANAGER_ROOT/versions/" -type l -printf "%f\n" | sort -r
