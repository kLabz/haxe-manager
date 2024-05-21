import eval.integers.Int64;
import eval.luv.Buffer;
import eval.luv.File.FileSync;
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

class LixTools {
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

	public static function resolveHaxe() {
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

	static var installReg = ~/^#\s@install:\slix\s--silent\sdownload\s"([^"]+)"\s/;

	static function getInstallHxml():String {
		final cwd = Utils.getCallSite();
		final haxe_libraries = Path.join([cwd, "haxe_libraries"]);

		var installHxml = "";

		function addHaxelib(lib:String, version:String) {
			installHxml += '-lib $lib:$version\n';
		}

		function addGitLib(lib:String, url:String) {
			installHxml += '-lib $lib:git:$url\n';
		}

		function processLib(hxml) {
			final lib = Path.withoutExtension(hxml);
			final contents = File.getContent(Path.join([haxe_libraries, hxml])).split("\n");

			// TODO: handle post-install
			for (line in contents) {
				if (installReg.match(line)) {
					final source = installReg.matched(1);
					final protocol = source.split(":").shift();

					switch protocol {
						case null:
							throw ParseError('Cannot parse install instructions for lib $lib: $source');

						case "haxelib":
							final parts = source.split("#");
							final libName = parts[0].substr(protocol.length + 2);
							addHaxelib(libName, parts[1]);

						case "gh" | "github":
							addGitLib(lib, "https" + source.substr(protocol.length));

						case "http" | "https":
							addGitLib(lib, source);

						case v:
							trace(v);
							addGitLib(lib, source); // This could work? xD
					}

					return;
				}
			}

			trace('Warning: installation instructions not found for $lib');
		}

		if (FileSystem.exists(haxe_libraries)) {
			for (lib in FileSystem.readDirectory(haxe_libraries)) {
				if (Path.extension(lib) == "hxml") processLib(lib);
			}

			return installHxml;
		} else {
			throw NotFound;
		}
	}

	public static function generateInstallHxml(file:String) {
		final installHxml = getInstallHxml();

		if (installHxml != "") {
			final cwd = Utils.getCallSite();
			final path = Path.isAbsolute(file) ? file : Path.join([cwd, file]);
			File.saveContent(path, installHxml);
			Sys.println('Saved lib installation instructions to $file');
		}
	}

	public static function applyLibs() {
		final installHxml = getInstallHxml();
		if (installHxml != "") {
			final cwd = Utils.getCallSite();
			final old_cwd = Sys.getCwd();
			Sys.setCwd(cwd);

			switch FileSync.mkstemp("install_XXXXXX") {
				case Error(e):
					Sys.setCwd(old_cwd);
					throw e;

				case Ok({name: name, file: file}):
					final hxml = name.toString() + ".hxml";

					FileSync.write(file, Int64.ZERO, [Buffer.fromString(installHxml)]);
					FileSync.close(file);
					FileSync.rename(name, hxml);
					Sys.command("hxlib", ["state", "load", hxml]);
					FileSync.unlink(hxml);
					Sys.setCwd(old_cwd);
			}
		}
	}
}