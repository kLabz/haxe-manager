import eval.luv.File;
import haxe.io.Path;
import sys.FileSystem;

inline var binDir = "bin";
inline var currentDir = "current";
inline var versionsDir = "versions";
inline var releasesDir = "releases";

function getVersions():Array<String> {
	if (!FileSystem.exists(versionsDir)) FileSystem.createDirectory(versionsDir);
	if (!FileSystem.isDirectory(versionsDir)) throw '${FileSystem.absolutePath(versionsDir)} should be a directory';
	return FileSystem.readDirectory(versionsDir);
}

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

private function unlinkCurrent():Void {
	inline function unlink(f:String) {
		if (FileSystem.exists('$currentDir/$f')) {
			FileSystem.deleteFile('$currentDir/$f');
		}
	}

	unlink('haxe');
	unlink('haxelib');
	unlink('std');
}

private function link(dir:String):Void {
	FileSync.symlink(Path.join(["..", dir, "haxe"]), Path.join([currentDir, "haxe"]));
	FileSync.symlink(Path.join(["..", dir, "haxelib"]), Path.join([currentDir, "haxelib"]));
	FileSync.symlink(Path.join(["..", dir, "std"]), Path.join([currentDir, "std"]));
}
