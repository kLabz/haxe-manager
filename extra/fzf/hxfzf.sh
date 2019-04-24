#!/bin/sh

# Get local dir
pwd=$(pwd)
cwd=$(pwd)
if [ -f ./pwd ]; then
  cwd=$(./pwd)
fi

# Get local hxmls (only build.hxml for now?)
# TODO: handle other hxmls
hxml="build.hxml"

# TODO: only ignore irrelevant std targets
haxe --cwd `pwd` "$hxml" "/opt/haxe/extra/fzf/classpath.hxml" 2> /dev/null \
  | grep "\[CLASSPATH\]: " \
  | sed -s 's/^\[CLASSPATH\]:\s//' \
  | grep -v "^$" \
  | grep -v "^/opt/haxe/extra/fzf/src/$" \
  | sed -rs "s,^([^/]),$cwd/\1," \
  | xargs -rn 1 realpath --relative-base="$pwd" -qs \
  | tr '\n' ' ' \
  | xargs ag --hidden --silent -f -g ".hx" \
    --ignore "/opt/haxe/std/cpp/*" \
    --ignore "/opt/haxe/std/cs/*" \
    --ignore "/opt/haxe/std/flash/*" \
    --ignore "/opt/haxe/std/java/*" \
    --ignore "/opt/haxe/std/hl/*" \
    --ignore "/opt/haxe/std/neko/*" \
    --ignore "/opt/haxe/std/php/*" \
    --ignore "/opt/haxe/std/python/*"
