package tools;

import haxe.io.Path;
import sys.Http;
import sys.io.File;

using StringTools;

class DownloadHelper {
	public static function download(url:String, out:String, cb:()->Void):Void {
		final output = File.write(out, true);
		final req = new Http(url);

		req.onError = function(msg) {
			output.close();
			throw '$msg while dowloading $url';
		};

		// Use custom request to write directly to file
		req.customRequest(false, output);

		// Follow redirections
		for (h in ["Location", "location"]) {
			if (req.responseHeaders.exists(h)) {
				var newUrl = resolveRedirection(url, req.responseHeaders.get(h));
				output.close();
				download(newUrl, out, cb);
				return;
			}
		}

		output.close();
		cb();
	}

	public static function extract(path:String):Null<String> {
		final pathData = new Path(path);
		final filename = pathData.file + (pathData.ext == null ? "" : "." + pathData.ext);

		Sys.println('Extracting $filename...');
		return switch (Path.extension(filename)) {
			case "zip": new ZipExtractor(File.read(path, true)).extract(pathData.dir);
			case "gz": new TgzExtractor(File.read(path, true)).extract(pathData.dir);
			case _: throw 'Unexpected release $filename';
		}
	}

	public static function resolveRedirection(base:String, redir:String):String {
		for (prefix in ["https://", "http://"]) {
			if (redir.startsWith(prefix)) return redir;
		}

		if (redir.startsWith("://")) {
			return base.substr(0, base.indexOf(":")) + redir;
		}

		if (redir.startsWith("/")) {
			return base.substr(0, base.indexOf("/", base.indexOf(":") + 2)) + redir;
		}

		return base.substr(0, base.lastIndexOf("/") + 1) + redir;
	}
}


