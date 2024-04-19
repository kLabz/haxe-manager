import eval.luv.File;
import haxe.io.Path;
import sys.FileSystem;

inline var binDir = "bin";
inline var currentDir = "current";
inline var versionsDir = "versions";
inline var releasesDir = "releases";

function getBuildUrl(v:String):Array<String> {
	// TODO: other OS, and arch variants
	return switch Sys.systemName() {
		case "Linux":
			['https://build.haxe.org/builds/haxe/linux64/', 'haxe_$v.tar.gz'];
		case "Mac":
			['https://build.haxe.org/builds/haxe/mac/', 'haxe_$v.tar.gz'];
		case "Windows":
			['https://build.haxe.org/builds/haxe/windows64/', 'haxe_$v.zip'];
		case os: throw 'OS $os is not supported (yet)';
	}
}

function getReleaseUrl(v:String):Array<String> {
	// TODO: other OS, and arch variants
	return switch Sys.systemName() {
		case "Linux":
			['https://github.com/HaxeFoundation/haxe/releases/download/$v/', 'haxe-$v-linux64.tar.gz'];
		case "Mac":
			['https://github.com/HaxeFoundation/haxe/releases/download/$v/', 'haxe-$v-osx.tar.gz'];
		case "Windows":
			['https://github.com/HaxeFoundation/haxe/releases/download/$v/', 'haxe-$v-win64.zip'];
		case os: throw 'OS $os is not supported (yet)';
	}
}

function getVersions():Array<String> {
	if (!FileSystem.exists(versionsDir)) FileSystem.createDirectory(versionsDir);
	if (!FileSystem.isDirectory(versionsDir)) throw '${FileSystem.absolutePath(versionsDir)} should be a directory';
	return FileSystem.readDirectory(versionsDir);
}

// TODO: windows vs symlinks
function hasVersion(v:String):Bool {
	final dir = Path.join([versionsDir, v]);
	return FileSystem.isDirectory(dir);
}

function selectVersion(v:String, ?skipCheck:Bool = false):Void {
	if (!skipCheck && !hasVersion(v)) throw 'Version $v is not installed';

	final dir = Path.join([versionsDir, v]);
	unlinkCurrent();
	link(dir);
}

function selectRelease(r:String):Void {
	final dir = Path.join([releasesDir, r]);
	if (!FileSystem.isDirectory(dir)) throw 'Version $r is not installed';

	unlinkCurrent();
	link(dir);
}

// TODO: unix vs windows
private function unlinkCurrent():Void {
	inline function unlink(f:String) {
		try FileSystem.deleteFile('$currentDir/$f') catch(_) {}
	}

	unlink('haxe');
	unlink('haxelib');
	unlink('std');
}

// TODO: unix vs windows
private function link(dir:String):Void {
	if (!FileSystem.exists(currentDir)) FileSystem.createDirectory(currentDir);
	FileSync.symlink(Path.join(["..", dir, "haxe"]), Path.join([currentDir, "haxe"]));
	FileSync.symlink(Path.join(["..", dir, "haxelib"]), Path.join([currentDir, "haxelib"]));
	FileSync.symlink(Path.join(["..", dir, "std"]), Path.join([currentDir, "std"]));
}
