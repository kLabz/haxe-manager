import haxe.io.Path;
import sys.FileSystem;
import sys.Http;
import sys.io.File;

class HaxeDownload {
	public static function main() {
		switch Sys.args() {
			case ["latest"]: downloadLatest();
			case ["latest", alias]: downloadLatest(alias);
			case ["aws", v] | ["nightly", v]: downloadNightly(v);
			case ["aws", v, alias] | ["nightly", v, alias]: downloadNightly(v, alias);
			case [f] if (FileSystem.exists(f)): throw "TODO";
			case [f, alias] if (FileSystem.exists(f)): throw "TODO";
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
		// trace('TODO: download file $filename as $alias from $url$filename');

		final path = Path.join([Utils.releasesDir, filename]);
		DownloadHelper.download(url + filename, path, () -> {
			trace('Downloaded $filename as $alias; TODO: symlinks');
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

class DownloadHelper {
	public static function download(url:String, out:String, cb:()->Void):Void {
		var output = File.write(out, true);
		var req = new Http(url);

		req.onError = function(msg) {
			trace("Error: " + msg);
			// trace(req.responseHeaders);
			output.close();
			throw msg;
		};

		// Use custom request to write directly to file
		req.customRequest(false, output);

		// Follow redirections
		if (req.responseHeaders.exists("Location")) {
			final newUrl = req.responseHeaders.get("Location");
			output.close();
			download(newUrl, out, cb);
		} else {
			output.close();
			cb();
		}
	}
}
