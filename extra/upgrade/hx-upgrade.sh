#!/bin/sh

HAXE_MANAGER_ROOT="/opt/haxe"
cd $HAXE_MANAGER_ROOT
git pull
cd - > /dev/null
