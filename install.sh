#!/bin/sh

ROOT=$(dirname $(readlink -f $0))

cd "$ROOT/bin"
echo "Please add $ROOT/bin to your PATH"
echo "Please set HAXE_STD_PATH to $ROOT/std"

mkdir ../releases
mkdir ../versions

# Download some versions
./hx-download "3.4.7"
# ./hx-download "4.0.0-preview.1"
# ./hx-download "4.0.0-preview.2"
# ./hx-download "4.0.0-preview.3"
./hx-download "4.0.0-preview.4"
# ./hx-download "aws" "haxe_latest" "dev"

# Select default version
# ./hx-select "3.4.7"
./hx-select "4.0.0-preview.4"

cd -
