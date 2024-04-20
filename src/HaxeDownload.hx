import eval.luv.File.FileSync;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.Process;

import tools.DownloadHelper;

class HaxeDownload {
	public static function main() {
		Utils.wrap(() -> run(Sys.args()));
	}

	public static function run(args:Array<String>):Void {
		switch args {
			// Nightlies support
			case ["latest"]: downloadLatest();
			case ["latest", alias]: downloadLatest(alias);
			case ["aws", v] | ["nightly", v]: downloadNightly(v);
			case ["aws", v, alias] | ["nightly", v, alias]: downloadNightly(v, alias);

			// TODO: reimplement local archive installation
			case [f] if (FileSystem.exists(f)): throw "TODO";
			case [f, alias] if (FileSystem.exists(f)): throw "TODO";

			// TODO: only sane looking semver should be considered here
			case [v]: downloadRelease(v);
			case [v, alias]: downloadRelease(v, alias);

			case _: displayUsage();
		}
	}

	static function downloadLatest(?alias:String = "dev"):Void {
		final url = Utils.getBuildUrl("latest");
		install(url[0], url[1], alias);
	}

	static function downloadNightly(v:String, ?alias:String):Void {
		v = HaxeNightlies.resolve(v);
		final url = Utils.getBuildUrl(v);
		install(url[0], url[1], alias);
	}

	static function downloadRelease(v:String, ?alias:String):Void {
		final url = Utils.getReleaseUrl(v);
		install(url[0], url[1], alias);
	}

	static function install(url:String, filename:String, ?alias:String):Void {
		final path = Path.join([Utils.releasesDir, filename]);

		DownloadHelper.download(url + filename, path, () -> {
			Sys.println('Downloaded $filename');
			final out = DownloadHelper.extract(path);
			FileSystem.deleteFile(path);

			final releasePath = Path.join([FileSystem.absolutePath(Utils.releasesDir), out]);

			if (alias == null) {
				final exe = switch Sys.systemName() {
					case "Windows": "haxe.exe";
					case _: "haxe";
				};

				final proc = new Process(Path.join([releasePath, exe]), ["--version"]);
				try {
					final code = proc.exitCode();
					if (code > 0) throw proc.stderr.readAll().toString();
					alias = StringTools.trim(proc.stdout.readAll().toString());
					proc.close();
				} catch (e) {
					proc.close();
					throw e;
				}
			}

			final versionPath = Path.join([Utils.versionsDir, alias]);
			try FileSystem.deleteFile(versionPath) catch(_) {}
			FileSync.symlink(releasePath, versionPath);
			Sys.println('Installed $filename as $alias');
		});
	}

	static function displayUsage() {
		Sys.println([
			"hx-download: missing argument(s)",
			"",
			"Usage: hx-download <VERSION> [AS_NAME]",
			"       Download official release VERSION (e.g., 4.3.0)",
			"       Save as AS_NAME if provided or use version number",
			"",
			"   or: hx-download latest [AS_NAME]",
			"       Download latest nightly",
			"       Save as AS_NAME if provided or use version number (with revision)",
			"",
			"   or: hx-download nightly <VERSION> [AS_NAME]",
			"   or: hx-download aws <VERSION> [AS_NAME]",
			"       Download specific nightly VERSION (e.g., 2023-01-22_development_dd5e467)",
			"       Save as AS_NAME if provided or use version number (with revision)"
		].join("\n"));
	}
}
