#!/bin/sh

ROOT=$(dirname $(readlink -f $0))

cd "$ROOT/bin"
echo "Please add $ROOT/bin to your PATH"
echo "Please set HAXE_STD_PATH to $ROOT/std"

if ! [ -e ../releases ]; then
	mkdir ../releases
fi

if ! [ -e ../versions ]; then
	mkdir ../versions
fi

# Install fzf if needed
if ! [ -x "$(command -v fzf)" ]; then
	wget "https://github.com/junegunn/fzf-bin/releases/download/0.17.4/fzf-0.17.4-linux_amd64.tgz"
	tar -xvf "fzf-0.17.4-linux_amd64.tgz"
	rm "fzf-0.17.4-linux_amd64.tgz"
fi

# Download some versions
./hx-download "3.4.7"
# ./hx-download "4.0.0-preview.1"
# ./hx-download "4.0.0-preview.2"
# ./hx-download "4.0.0-preview.3"
./hx-download "4.0.0-preview.4"
./hx-download "aws" "latest" "dev"

# Select default version
# ./hx-select "3.4.7"
./hx-select "4.0.0-preview.4"

cd -
