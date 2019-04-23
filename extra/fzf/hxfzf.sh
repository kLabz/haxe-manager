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
    --ignore "/usr/lib/haxe/std/cpp/*" \
    --ignore "/usr/lib/haxe/std/cs/*" \
    --ignore "/usr/lib/haxe/std/flash/*" \
    --ignore "/usr/lib/haxe/std/java/*" \
    --ignore "/usr/lib/haxe/std/hl/*" \
    --ignore "/usr/lib/haxe/std/neko/*" \
    --ignore "/usr/lib/haxe/std/php/*" \
    --ignore "/usr/lib/haxe/std/python/*"
