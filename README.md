# Haxe Manager

Easily download and switch haxe versions (currently tested on
`ubuntu-latest`, `macos-latest` and `windows-latest` via github actions).

Run `install.sh` (`install.bat` on Windows) and update `PATH` / `HAXE_STD_PATH` as
requested.

Note for windows users: [how to set your PATH environment variable](https://www.computerhope.com/issues/ch000549.htm)

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

## Included `haxelib` version

If you need to run commands from `haxelib` nightlies, but you currently selected
Haxe version is bundling an older haxelib, you can access Haxe Manager's bundled
version of haxelib through `hxlib`:

Usage: `hxlib state load install.hxml` / `hxlib state save install.hxml`

## [lix](https://github.com/lix-pm/) related tooling

Switch to Haxe version specified in `.haxerc` with `hx rc`. Alternatively, one-off
operations can be done with `hx with rc [haxe compiler args]` without altering
currently selected Haxe version.

### `haxe_libraries`

Install libraries as defined in lix's `haxe_libraries` folder: `hx lix-libs`

Alternatively, generate a `install.hxml` file (to be used with
`haxelib state load install.hxml`) by running `hx lix-to-install install.hxml`

