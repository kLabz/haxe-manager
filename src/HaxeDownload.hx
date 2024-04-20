import eval.luv.File.FileSync;
import haxe.io.Path;
import sys.FileSystem;

import tools.DownloadHelper;

class HaxeDownload {
	public static function main() {
		// TODO: catch exceptions and display nicer errors
		switch Sys.args() {
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

	// TODO: Install as "5.0.0-alpha.1+569e52e" if no alias (using -version)
	static function downloadNightly(v:String, ?alias:String):Void {
		v = HaxeNightlies.resolve(v);
		if (alias == null) alias = v;
		final url = Utils.getBuildUrl(v);
		install(url[0], url[1], alias);
	}

	static function downloadRelease(v:String, ?alias:String):Void {
		if (alias == null) alias = v;
		final url = Utils.getReleaseUrl(v);
		install(url[0], url[1], alias);
	}

	static function install(url:String, filename:String, alias:String):Void {
		final path = Path.join([Utils.releasesDir, filename]);

		DownloadHelper.download(url + filename, path, () -> {
			Sys.println('Downloaded $filename');
			final out = DownloadHelper.extract(path);
			FileSystem.deleteFile(path);

			final versionPath = Path.join([Utils.versionsDir, alias]);
			try FileSystem.deleteFile(versionPath) catch(_) {}
			FileSync.symlink(Path.join([FileSystem.absolutePath(Utils.releasesDir), out]), versionPath);
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
