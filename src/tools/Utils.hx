package tools;

import eval.luv.File;
import haxe.Utf8;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.Process;

import ansi.ANSI;

class Utils {
	public static inline var binDir = "bin";
	public static inline var currentDir = "current";
	public static inline var versionsDir = "versions";
	public static inline var releasesDir = "releases";

	public static function wrap(f:()->Void):Void {
		try f() catch (e:String) failWith(e);
	}

	public static function failWith(msg:String):Void {
		displayError(msg);
		Sys.exit(1);
	}

	public static function displayError(msg:String):Void {
		Sys.stderr().writeString(
			ANSI.set(RedBack) + ANSI.set(Black) +
			' ERROR ' +
			ANSI.set(Off) +
			' ' + msg + '\n'
		);

		Sys.stderr().flush();
	}

	public static function getBuildUrl(v:String):Array<String> {
		return switch Sys.systemName() {
			case "Linux" if (isArm64()):
				['https://build.haxe.org/builds/haxe/linux-arm64/', 'haxe_$v.tar.gz'];
			case "Linux":
				['https://build.haxe.org/builds/haxe/linux64/', 'haxe_$v.tar.gz'];
			case "Mac":
				['https://build.haxe.org/builds/haxe/mac/', 'haxe_$v.tar.gz'];
			case "Windows":
				['https://build.haxe.org/builds/haxe/windows64/', 'haxe_$v.zip'];
			case os: throw 'OS $os is not supported (yet)';
		}
	}

	public static function getReleaseUrl(v:String):Array<String> {
		return switch Sys.systemName() {
			case "Linux" if (isArm64()):
				// TODO
				throw "Haxe releases don't include linux-arm64 binaries yet";
				// ['https://github.com/HaxeFoundation/haxe/releases/download/$v/', 'haxe-$v-linux-arm64.tar.gz'];
			case "Linux":
				['https://github.com/HaxeFoundation/haxe/releases/download/$v/', 'haxe-$v-linux64.tar.gz'];
			case "Mac":
				['https://github.com/HaxeFoundation/haxe/releases/download/$v/', 'haxe-$v-osx.tar.gz'];
			case "Windows":
				['https://github.com/HaxeFoundation/haxe/releases/download/$v/', 'haxe-$v-win64.zip'];
			case os: throw 'OS $os is not supported (yet)';
		}
	}

	static function isArm64():Bool {
		final proc = new Process("uname", ["-m"]);
		return try {
			final out = StringTools.trim(proc.stdout.readAll().toString());
			proc.close();
			out == "arm" || out == "aarch64";
		} catch(_) {
			proc.close();
			false;
		}
	}

	@:haxe.warning("-WDeprecated")
	public static function getVersions():Array<String> {
		if (!FileSystem.exists(versionsDir)) FileSystem.createDirectory(versionsDir);
		if (!FileSystem.isDirectory(versionsDir)) throw '${FileSystem.absolutePath(versionsDir)} should be a directory';

		final ret = FileSystem.readDirectory(versionsDir);
		ret.sort((a, b) -> Utf8.compare(b,a));
		return ret;
	}

	public static function getCurrent():Null<String> {
		if (!FileSystem.exists(currentDir)) return null;

		return switch FileSync.readLink(currentDir) {
			case Ok(res): getVersionString(res.toString());
			case Error(_): null;
		};
	}

	public static function getCurrentName():Null<String> {
		if (!FileSystem.exists(currentDir)) return null;

		return switch FileSync.readLink(currentDir) {
			case Ok(res): Path.withoutDirectory(res.toString());
			case Error(_): null;
		};
	}

	public static function getCurrentFull():Null<String> {
		return switch getCurrentName() {
			case null | "": getCurrent();
			case name: name + ' (' + getCurrent() + ')';
		};
	}

	public static function getVersionString(path:String):Null<String> {
		final exe = switch Sys.systemName() {
			case "Windows": "haxe.exe";
			case _: "haxe";
		};

		final proc = new Process(Path.join([path, exe]), ["--version"]);
		try {
			final code = proc.exitCode();
			if (code > 0) throw proc.stderr.readAll().toString();
			final v = StringTools.trim(proc.stdout.readAll().toString());
			proc.close();
			return v;
		} catch (_) {
			proc.close();
			return null;
		}
	}

	public static function hasVersion(v:String):Bool {
		final dir = Path.join([versionsDir, v]);
		return FileSystem.exists(dir);
	}

	public static function selectVersion(v:String, ?skipCheck:Bool = false):Void {
		if (!skipCheck && !hasVersion(v)) throw 'Version $v is not installed';

		final dir = Path.join([versionsDir, v]);
		unlinkCurrent();
		link(dir);
	}

	public static function selectRelease(r:String):Void {
		final dir = Path.join([releasesDir, r]);
		if (!FileSystem.exists(dir)) throw 'Version $r is not installed';

		unlinkCurrent();
		link(dir);
	}

	public static function getCallSite():String {
		return Sys.getEnv("CALL_SITE");
	}

	static function unlinkCurrent():Void {
		if (FileSystem.exists(currentDir)) FileSync.unlink(currentDir);
	}

	static function link(dir:String):Void {
		if (Sys.systemName() == "Windows") {
			switch FileSync.readLink(dir) {
				case Ok(dir): FileSync.symlink(dir, currentDir, [SYMLINK_DIR]);
				case Error(_): FileSync.symlink(dir, currentDir, [SYMLINK_DIR]);
			}
		} else {
			FileSync.symlink(dir, currentDir, [SYMLINK_DIR]);
		}
	}
}
