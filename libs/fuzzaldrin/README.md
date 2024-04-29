# fuzzaldrin

From https://github.com/jeremyfa/fuzzaldrin/

Fuzzy filtering and string scoring (ported to haxe from https://github.com/atom/fuzzaldrin).

The original library is used by [Atom](http://atom.io) and so its focus will be on
scoring and filtering paths, methods, and other things common when writing code.
It therefore will specialize in handling common patterns in these types of
strings such as characters like `/`, `-`, and `_`, and also handling of
camel cased text.

## Fork

The original haxe library has been "forked" and included in Haxe Manager
repository because Haxe Manager needs to be able to run without `haxelib` (or,
to be more precise, without its `neko` dependency).

Note that some changes have been made to make it fit my needs, that can be seen
in the git history of current directory (well, that was before the initial PR got
squashed...).
