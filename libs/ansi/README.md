# ansi

From https://github.com/SmilyOrg/ansi

Haxe utility for working with ANSI escape sequences.

Provides functions that return a String with the appropriate ANSI escape sequence. This is usually written to standard output for the hosting console to process.

**Note**: If the console doesn't support the escape sequences (e.g. default Command Prompt on Windows), you're going to see garbage.

Tested with the neko target and [ansicon](https://github.com/adoxa/ansicon).

## Fork

The original haxe library has been "forked" and included in Haxe Manager
repository because Haxe Manager needs to be able to run without `haxelib` (or,
to be more precise, without its `neko` dependency).

Only change I've made so far was to handle a Haxe warning.
