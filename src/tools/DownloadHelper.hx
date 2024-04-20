package tools;

import haxe.io.Path;
import sys.Http;
import sys.io.File;

class DownloadHelper {
	public static function download(url:String, out:String, cb:()->Void):Void {
		final output = File.write(out, true);
		final req = new Http(url);

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
}


