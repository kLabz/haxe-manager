import haxelib.SemVer;
import sys.io.File;
import haxe.Json;
import sys.FileSystem;
import haxe.io.Path;

import tools.Utils;

class HaxeRc {
	public static function resolve() {
		final cwd = Utils.getCallSite();

		// TODO (?): check parent directories too
		final rc = Path.join([cwd, ".haxerc"]);

		if (FileSystem.exists(rc)) {
			try {
				final version = Json.parse(File.getContent(rc)).version;

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
			} catch (e) {
				Utils.displayError('Could not get Haxe version from .haxerc: $e');
				Sys.exit(1);
			}
		} else {
			Utils.displayError('Did not find any .haxerc to apply');
			Sys.exit(1);
		}
	}
}
