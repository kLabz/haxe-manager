import haxelib.SemVer;
import sys.io.File;
import haxe.Json;
import sys.FileSystem;
import haxe.io.Path;

import tools.Utils;

enum HaxeRcError {
	NotFound;
	ParseError(err:String);
}

class HaxeRc {
	public static function safeGetRc():Null<String> {
		return try getRc() catch(_) null;
	}

	public static function getRc():Null<String> {
		final cwd = Utils.getCallSite();

		// TODO (?): check parent directories too
		final rc = Path.join([cwd, ".haxerc"]);

		if (FileSystem.exists(rc)) {
			try {
				final version = Json.parse(File.getContent(rc)).version;
				return version;
			} catch (e) {
				throw ParseError(Std.string(e));
			}
		} else {
			throw NotFound;
		}
	}

	public static function resolve() {
		try {
			final version = getRc();

			if (SemVer.isValid(version)) {
				HaxeDownload.downloadRelease(version, r -> HaxeSelect.select(r));
			} else if (HaxeNightlies.isValid(version)) {
				switch (Utils.resolveRelease(version)) {
					case null:
						HaxeDownload.downloadNightly(version, r -> HaxeSelect.select(r));
					case r:
						HaxeSelect.select(r);
				}
			}
		} catch (e:HaxeRcError) {
			switch e {
				case NotFound:
					Utils.displayError('Did not find any .haxerc to apply');
				case ParseError(e):
					Utils.displayError('Could not get Haxe version from .haxerc: $e');
			}

			Sys.exit(1);
		}
	}
}
