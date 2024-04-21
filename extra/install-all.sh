#!/bin/bash

ROOT=$(dirname $(readlink -f $0))

sh "$ROOT/++haxe/install.sh"
sh "$ROOT/fzf/install.sh"
sh "$ROOT/list/install.sh"
sh "$ROOT/local/install.sh"
sh "$ROOT/make-haxe/install.sh"
sh "$ROOT/nightlies/install.sh"
sh "$ROOT/rofi/install.sh"
sh "$ROOT/upgrade/install.sh"
