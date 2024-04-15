#!/bin/bash

HAXE_MANAGER_ROOT="/opt/haxe"

find "$HAXE_MANAGER_ROOT/versions/" -type l -exec basename {} \; | sort -r
