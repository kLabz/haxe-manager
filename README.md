# Haxe Manager

Easily download and switch haxe versions on unix/WSL (currently only uses the linux64 target).

Run `install.sh` and update `PATH` / `HAXE_STD_PATH` as requested.

## Select a version

Run `hx` to display the haxe version switch (using [`fzf`](https://github.com/junegunn/fzf)).

You can also skip the version picker by using directly `hx-select 3.4.7`.

## Installing / updating versions

Syntax: `hx-download [aws] [release name] [alias]`.

Run `hx-download 3.4.4` to download version `3.4.4` (doesn't handle versions <
`3.2.0`). To download from AWS builds, use `hx-download aws 2018-09-27_development_e991967`,
for example.

You can also run `hx-download aws latest dev` to download `haxe_latest` from AWS as `dev` version.
