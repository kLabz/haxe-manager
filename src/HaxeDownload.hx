import ansi.ANSI;
import eval.luv.File.FileSync;
import haxe.io.Path;
import sys.FileSystem;

import haxelib.SemVer;
import tools.DownloadHelper;
import tools.Utils;

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

			case [v] if (SemVer.isValid(v)): downloadRelease(v);
			case [v, alias] if (SemVer.isValid(v)): downloadRelease(v, alias);

			case [v] if (HaxeNightlies.isValid(v)): downloadNightly(v);
			case [v, alias] if (HaxeNightlies.isValid(v)): downloadNightly(v, alias);

			case [v] | [v, _]:
				Utils.displayError('hx download: $v is not a valid release version\n');
				displayUsage();

			case _:
				Utils.displayError("hx download: missing argument(s)\n");
				displayUsage();
		}
	}

	public static function installLocal(file:String, ?alias:String):Void {
		file = Path.isAbsolute(file) ? file : Path.join([Utils.getCallSite(), file]);
		if (!FileSystem.exists(file)) throw 'Cannot find release file $file';

		// Copy archive to releases/
		final filename = Path.withoutDirectory(file);
		final dest = Path.join([Utils.releasesDir, filename]);
		FileSync.copyFile(file, dest);

		// Install release
		installFile(dest, filename, alias);
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
		url = url + filename;
		filename = Path.withoutDirectory(filename);
		final path = Path.join([Utils.releasesDir, filename]);

		DownloadHelper.download(url, path, () -> {
			Sys.println('Downloaded $filename');
			installFile(path, filename, alias);
		});
	}

	static function installFile(path:String, filename:String, ?alias:String):Void {
		final out = DownloadHelper.extract(path);
		FileSystem.deleteFile(path);

		final releasePath = Path.join([FileSystem.absolutePath(Utils.releasesDir), out]);
		if (alias == null) alias = Utils.getVersionString(releasePath);

		final versionPath = Path.join([Utils.versionsDir, alias]);
		try FileSystem.deleteFile(versionPath) catch(_) {}
		FileSync.symlink(releasePath, versionPath);
		Sys.println('Installed $filename as $alias');
	}

	public static function displayUsage() {
		var ORANGE = ANSI.CSI + '38;5;208m';
		var RESET = ANSI.set(Off);
		var UNDERLINE = ANSI.set(Underline);
		var UNDERLINE_OFF = ANSI.set(UnderlineOff);
		var BOLD = ANSI.set(Bold);
		var BOLD_OFF = ANSI.set(BoldOff);

		Sys.println([
			'Usage: ${ORANGE}hx download ${UNDERLINE}<VERSION>${UNDERLINE_OFF} ${UNDERLINE}[AS_NAME]${RESET}',
			'       Download official release ${BOLD}VERSION${BOLD_OFF} (e.g., ${BOLD}4.3.0${BOLD_OFF})',
			'       Save as ${BOLD}AS_NAME${BOLD_OFF} if provided or use version number',
			'',
			'   or: ${ORANGE}hx download latest ${UNDERLINE}[AS_NAME]${RESET}',
			'       Download latest nightly',
			'       Save as ${BOLD}AS_NAME${BOLD_OFF} if provided or use version number (with revision)',
			'',
			'   or: ${ORANGE}hx download nightly ${UNDERLINE}<VERSION>${UNDERLINE_OFF} ${UNDERLINE}[AS_NAME]${RESET}',
			'   or: ${ORANGE}hx download aws ${UNDERLINE}<VERSION>${UNDERLINE_OFF} ${UNDERLINE}[AS_NAME]${RESET}',
			'       Download specific nightly ${BOLD}VERSION${BOLD_OFF} (e.g., ${BOLD}2023-01-22_development_dd5e467${BOLD_OFF})',
			'       Save as ${BOLD}AS_NAME${BOLD_OFF} if provided or use version number (with revision)',
			'       Note: short hash ${BOLD}VERSION${BOLD_OFF} is also supported for development nightlies (e.g. ${BOLD}dd5e467${BOLD_OFF})'
		].join("\n"));
	}
}
