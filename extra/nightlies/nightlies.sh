#!/bin/bash

HAXE_MANAGER_ROOT="/opt/haxe"
HAXE_REPO="https://github.com/HaxeFoundation/haxe.git"
NIGHTLIES_ROOT="$HAXE_MANAGER_ROOT/extra/nightlies/data"

UPDATED=0

ensure_setup () {
	if [ ! -e $NIGHTLIES_ROOT ]; then
		echo "Initialize nightlies data..."
		git clone --bare "$HAXE_REPO" "$NIGHTLIES_ROOT" --quiet
		echo "Nightlies data ready."
	fi
}

update_nightlies_data () {
	ensure_setup
	echo "Updating nightlies data..."
	git --git-dir "$NIGHTLIES_ROOT" fetch "$HAXE_REPO" --quiet
	UPDATED=1
}

get_nightly () {
	ensure_setup

	local SHA="$1"
	local DATE=$(TZ=UTC git --git-dir "$NIGHTLIES_ROOT" show --quiet --date='format-local:%Y-%m-%d' --format="%cd" "$SHA" 2> /dev/null || echo "")

	if [ ! -z "$DATE" ]; then
		local BRANCH=$(git --git-dir "$NIGHTLIES_ROOT" branch development --contains "$SHA" --quiet 2> /dev/null || echo "")
		if [ ! -z "$BRANCH" ]; then
			local SHORT_SHA=$(git --git-dir "$NIGHTLIES_ROOT" rev-parse "$SHA" | cut -c1-7)
			echo "${DATE}_development_${SHORT_SHA}"
		else
			echo "Error: only revisions from branch development are supported atm";
			exit 1
		fi
	elif [ "$UPDATED" -eq 0 ]; then
		update_nightlies_data
		get_nightly "$SHA"
	else
		echo "Error: cannot find revision $SHA"
		exit 1
	fi
}


REF="$1"

if [ -z "$REF" ]; then
	echo "hx-nightlies: missing argument(s)"
	echo ""
	echo "Usage: hx-nightlies <HASH> [AS_NAME]"
	echo "       Resolve nightly from [short] hash HASH"
	echo "       Install it as AS_NAME and set it as current Haxe version"
	exit 1
else
	FILENAME=$(get_nightly "$REF")
	AS="$2"
	hx-download nightly $FILENAME $AS
	hx $AS
fi
