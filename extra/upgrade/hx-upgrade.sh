#!/bin/bash

HAXE_MANAGER_ROOT="/opt/haxe"
cd $HAXE_MANAGER_ROOT
git pull
./install.sh
cd - > /dev/null
