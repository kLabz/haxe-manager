#!/bin/bash

# Get local dir
pwd=$(pwd)
cwd=$(pwd)
if [ -f ./pwd ]; then
	cwd=$(./pwd)
fi

# Resolve hxml file
hxml="$1"
if [ -z "$hxml" ]; then
  hxml="build.hxml"
fi

# Get data from compiler (target, class paths)
out=$(haxe --cwd `pwd` "$hxml" /opt/haxe/extra/fzf/classpath.hxml 2> /dev/null)

# Process class paths
folders=$(echo "$out" \
	| grep "\[CLASSPATH\]: " \
	| sed -s 's/^\[CLASSPATH\]:\s//' \
	| sed -rs "s,^([^/]),$cwd/\1," \
	| xargs -n 1 realpath --relative-base="$pwd" -qs
)

# Prepare std target filter
target=$(echo -n "$out" | grep "\[TARGET\]: " | sed -s 's/^\[TARGET\]:\s//')
targets="js hl cpp cppia cs java jvm lua swf neko php python interp"
for t in $targets; do
  if [ ! "$t" = "$target" ]; then
    if [ -z "$targetFilter" ]; then
      targetFilter="$t"
    else
      targetFilter="$targetFilter\|$t"
    fi
  fi
done

# Get relevant files
echo "$folders" \
  | tr '\n' ' ' \
  | xargs ag --hidden --silent -f -g ".hx" \
  | grep -v "^/opt/haxe/std/\($targetFilter\)/"
