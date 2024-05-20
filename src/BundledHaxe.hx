import sys.io.File;
import haxe.io.Path;
import sys.FileSystem;

import tools.DownloadHelper;
import tools.Utils;

class BundledHaxe {
	static var OS = ["Linux", "Mac", "Windows"];
	static var current = Path.join([Utils.bundleDir, ".current"]);

	public static function getBundledVersion():String {
		return StringTools.trim(File.getContent(current));
	}

	public static function setBundledVersion(version:String):Void {
		final v = HaxeNightlies.resolve(version);

		function getOsPath(os) {
			return switch os {
				case "Linux": "linux64";
				case "Windows": "windows64";
				case "Mac": "mac";
				case _: throw 'Unexpected os $os';
			}
		}

		function updateCurrent() {
			final prev = getBundledVersion();

			if (prev != version) {
				for (os in OS) {
					final path = Path.join([Utils.bundleDir, getOsPath(os) + "_" + prev]);
					Utils.rmdir(path);
					Sys.println('Removed $path');
				}

				File.saveContent(current, version);
				// TODO: git operations
				Sys.println('Set current bundled haxe version as $version');
			}
		}

		final os = OS.copy();

		function next() {
			if (os.length == 0) return updateCurrent();

			final os = os.pop();
			final dest = Path.join([Utils.bundleDir, getOsPath(os) + "_" + version]);
			if (FileSystem.exists(dest)) {
				Sys.println('Bundled version $version for $os already exists');
				return next();
			}

			final url = Utils.getBuildUrl(v, os);
			final filename = Path.withoutDirectory(url[1]);
			final path = Path.join([Utils.bundleDir, filename]);

			DownloadHelper.download(url[0] + filename, path, () -> {
				Sys.println('Downloaded $filename');
				final out = DownloadHelper.extract(path);
				FileSystem.deleteFile(path);
				FileSystem.rename(Path.join([Utils.bundleDir, out]), dest);
				next();
			});
		}

		next();
	}
}
