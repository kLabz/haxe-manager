#!/bin/sh

# Handle kill signal
trap cleanup 1 2 3 6
cleanup()
{
	exit 0
}

cwd="/opt/haxe/extra/watcher/"

# Do not watch if no args
if [ -z "$1" ]; then
	haxe
	exit 0
fi

# Check if haxe server is available when asked to use it
if [ ! -z $HAXE_COMPILATION_SERVER ]; then
	if ! haxe --connect $HAXE_COMPILATION_SERVER --version; then
		echo "Compilation server not available on port $HAXE_COMPILATION_SERVER"
		exit 1
	fi
fi

while true; do
	if [ ! -z $HAXE_COMPILATION_SERVER ]; then
		echo "Using compilation server on port $HAXE_COMPILATION_SERVER"
		/usr/bin/time -f "Compiled in %e seconds" haxe --connect $HAXE_COMPILATION_SERVER $@
	else
		echo "NOT using compilation server"
		/usr/bin/time -f "Compiled in %e seconds" haxe $@
	fi

	haxe -cp "$cwd" -D watcher-path=$cwd --macro "Watcher.waitForChange()" $@
done
