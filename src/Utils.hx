import eval.luv.File;
import haxe.io.Path;
import sys.FileSystem;

inline var binDir = "bin";
inline var currentDir = "current";
inline var versionsDir = "versions";
inline var releasesDir = "releases";

function wrap(f:()->Void):Void {
	try f() catch (e:String) failWith(e);
}

function failWith(msg:String):Void {
	Sys.stderr().writeString('Error: $msg\n');
	Sys.exit(1);
}

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

	final ret = FileSystem.readDirectory(versionsDir);
	ret.sort((a,b) -> a > b ? -1 : 1);
	return ret;
}

function getCurrent():Null<String> {
	// TODO
	return "5.0.0-alpha.1+db842bf";
}

function hasVersion(v:String):Bool {
	final dir = Path.join([versionsDir, v]);
	return FileSystem.exists(dir);
}

function selectVersion(v:String, ?skipCheck:Bool = false):Void {
	if (!skipCheck && !hasVersion(v)) throw 'Version $v is not installed';

	final dir = Path.join([versionsDir, v]);
	unlinkCurrent();
	link(dir);
}

function selectRelease(r:String):Void {
	final dir = Path.join([releasesDir, r]);
	if (!FileSystem.exists(dir)) throw 'Version $r is not installed';

	unlinkCurrent();
	link(dir);
}

private function unlinkCurrent():Void {
	if (FileSystem.exists(currentDir)) FileSync.unlink(currentDir);
}

private function link(dir:String):Void {
	switch FileSync.readLink(dir) {
		case Ok(dir): FileSync.symlink(dir, currentDir, [SYMLINK_DIR]);
		case Error(_): FileSync.symlink(dir, currentDir, [SYMLINK_DIR]);
	}
}
