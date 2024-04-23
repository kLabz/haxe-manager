# Haxe Manager

Easily download and switch haxe versions (currently tested on
`ubuntu-latest`, `macos-latest` and `windows-latest` via github actions).

Run `install.sh` (`install.bat` on Windows) and update `PATH` / `HAXE_STD_PATH` as
requested.

## Select a version

Run `hx` to display the haxe version switch (using a Haxe port of [`fzf`](https://github.com/junegunn/fzf)
picker).

You can also skip the version picker by using directly `hx 4.3.0` or `hx select
4.3.0` (or any other version/alias you have installed).

## Installing / updating versions

Use `hx download` tool to download haxe versions:

```
Usage: hx download <VERSION> [AS_NAME]
       Download official release VERSION (e.g., 4.3.0)
       Save as AS_NAME if provided or use version number

   or: hx download latest [AS_NAME]
       Download latest nightly
       Save as AS_NAME if provided or use version number (with revision)

   or: hx download nightly <VERSION> [AS_NAME]
   or: hx download aws <VERSION> [AS_NAME]
       Download specific nightly VERSION (e.g., 2023-01-22_development_dd5e467)
       Save as AS_NAME if provided or use version number (with revision)
       Note: short hash VERSION is also supported for development nightlies (e.g. dd5e467)
```

### Installing archive

If you already have an archive available (a nightly from a branch other than
`development`, for example), you can install it with:

`hx install my_haxe_release.tar.gz [AS_NAME]`

## List available versions

Use `hx list` to get a list of all haxe versions available throught your (local)
haxe-manager.

## Display currently selected version

Use `hx current` to display currently selected Haxe version string (equivalent
to running `haxe --version`).

On Unix, you can also run:
- `hx current --name` to get the name under which that version is installed
- `hx current --full` to get both name and version string (`[NAME] ([VERSION])`)

## List all Haxe modules for current hxml

Prints a list of all `.hx` files in all your classpath, to be passed to `fzf`
or other tools.

Usage: `hx list-modules [compile.hxml]` (will default to `build.hxml`)


## Included tools

`extra/` folder contains optional tools you can install individually with their
`install.sh` script or all at once with `install-all.sh`.

Note that those have been written when Haxe Manager was unix only and probably
can't work at all on Windows.

### `++haxe`

Note if you're using Haxe >= 4.3.0: this is not useful anymore, since
[pretty errors](https://github.com/HaxeFoundation/haxe/pull/10863) were added there.

Wraps `haxe` with a nodejs wrapper that parses and pretty prints Haxe errors,
trying to guess the error hierarchy and displaying highlighted sources instead
of just positions.

Usage: `++haxe <args you would pass to haxe>`

### `make-haxe`

Mostly useful for bisecting or when building and switching haxe versions often.

Wraps Haxe repository's `make haxe` with some cache that will be applied when
git state is clean (or when you pass `--force-cache`). Build result (`haxe` and
`haxelib` binaries) are stored in haxe-manager cache to avoid building next time.

### `hx-mklocal`

Save your current binaries + std from your local Haxe repository as a named
version that you can use with haxe-manager.

Usage: from your Haxe repository, `hx-mklocal . custom-4.4.0` (replace `.` with
the path to your repository if you're executing from somewhere else)

### `hx-upgrade`

Update your local (git) copy of haxe-manager.

### `rofi-haxe`

[rofi](https://github.com/davatorium/rofi) wrapper to `hx` command, to graphically select a Haxe version.

