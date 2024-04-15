#!/bin/sh

ROOT=$(dirname $(readlink -f $0))

mkdir -p "$ROOT/releases"
mkdir -p "$ROOT/versions"

# Install fzf if needed
if ! [ -x "$(command -v fzf)" ]; then
	cd "$ROOT/bin"

	BUILD_OS="linux"
	if [[ "$OSTYPE" == "darwin"* ]]; then
		BUILD_OS="darwin"
	fi

	wget "https://github.com/junegunn/fzf-bin/releases/download/0.17.4/fzf-0.17.4-${BUILD_OS}_amd64.tgz"
	tar -xf "fzf-0.17.4-${BUILD_OS}_amd64.tgz"
	rm "fzf-0.17.4-${BUILD_OS}_amd64.tgz"
	cd - > /dev/null
fi

if [ -z "$SKIP_DEFAULTS" ]; then
	# Download some versions
	PATH=$PATH:$ROOT/bin hx-download "3.4.7"
	PATH=$PATH:$ROOT/bin hx-download "4.2.5"
	PATH=$PATH:$ROOT/bin hx-download "4.3.0"
	PATH=$PATH:$ROOT/bin hx-download "latest"

	# Select default version
	PATH=$PATH:$ROOT/bin hx-select "4.3.0"
fi

echo "Please add $ROOT/bin to your PATH"
echo "Please set HAXE_STD_PATH to $ROOT/current/std"
