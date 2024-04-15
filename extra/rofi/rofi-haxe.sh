#!/bin/bash

version=$(list-haxe-versions | rofi -dmenu -p "Set haxe version to" -no-custom -matching fuzzy -sorting-method fzf); hx-select $version
