import haxe.io.Path;
import sys.FileSystem;
import sys.Http;
import sys.io.File;

class HaxeDownload {
	public static function main() {
		trace("hx-download");
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
		trace('TODO: download file $filename as $alias from $url$filename');

		var req = new Http('$url$filename');
		req.setHeader("User-Agent", ""); // or any user-agent
		req.onBytes = function(bytes) {
			// trace("On bytes");
			// for (k=>v in req.responseHeaders) trace(k,v);

			if (req.responseHeaders.exists("Location")) {
				final newUrl = req.responseHeaders.get("Location");
				// trace(url + filename);
				trace(newUrl);

				var req2 = new Http(newUrl);
				req2.setHeader("User-Agent", ""); // or any user-agent
				// req2.setHeader("X-GitHub-Request-Id", req.responseHeaders.get("X-GitHub-Request-Id"));
				req2.onBytes = function(bytes) {
					// trace("On bytes");
					trace(req2.responseHeaders);
					final out = Path.join([Utils.releasesDir, filename]);
					trace('Save to $out');
					File.saveBytes(out, bytes);
				};

				req2.onError = function(msg) {
					trace("Error");
					trace(req2.responseHeaders);
					trace(msg);
					throw msg;
				};

				trace('Go (redirection)');
				req2.request();

				// var client = new http.HttpClient();
				// client.get(newUrl, null, [
				// 	"X-GitHub-Request-Id" => req.responseHeaders.get("X-GitHub-Request-Id")
				// ]).then(res -> {
				// 	trace("On bytes");
				// 	final out = Path.join([Utils.releasesDir, filename]);
				// 	trace('Save to $out');
				// 	File.saveBytes(out, res.response.body);
				// }, error -> {
				// 	trace("error");
				// 	trace(error.message);
				// 	throw error;
				// });
			} else {
				final out = Path.join([Utils.releasesDir, filename]);
				trace('Save to $out');
				File.saveBytes(out, bytes);
			}
		};

		req.onError = function(msg) {
			trace("Error");
			trace(req.responseHeaders);
			trace(msg);
			throw msg;
		};

		trace('Go');
		req.request();

		// var client = new http.HttpClient();
		// client.get('$url$filename').then(res -> {
		// 	trace("On bytes");
		// 	final out = Path.join([Utils.releasesDir, filename]);
		// 	trace('Save to $out');
		// 	File.saveBytes(out, res.response.body);
		// }, error -> {
		// 	trace("error");
		// 	trace(error);
		// 	throw error;
		// });
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
