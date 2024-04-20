import haxe.io.BytesInput;
import haxe.zip.InflateImpl;
import eval.luv.File.FileMode;
import eval.luv.File.FileSync;
import haxe.io.Bytes;
import haxe.io.Input;
import haxe.io.Path;
import sys.FileSystem;
import sys.Http;
import sys.io.File;

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

class TgzExtractor extends format.tgz.Reader {
	public function extract(dest:String):Null<String> {
		try {
			final tmp = new haxe.io.BytesOutput();
			final gz = new format.gz.Reader(i);
			gz.readHeader();

			final extractor = new TarExtractor(new TgzBytesInput(i));
			return extractor.extract(dest);
		} catch(e) {
			i.close();
			throw e;
		}
	}
}

class TgzBytesInput extends BytesInput {
	var inflate:InflateImpl;

	public function new(i:Input) {
		this.inflate = new InflateImpl(i, false, false);
		super(Bytes.alloc(0));
	}

	override function readByte():Int {
		var buf = Bytes.alloc(1);
		var len = inflate.readBytes(buf, 0, 1);
		return buf.get(0);
	}

	override function readBytes(buf:Bytes, pos:Int, len:Int):Int {
		return inflate.readBytes(buf, 0, len);
	}
}

class TarExtractor extends format.tar.Reader {
	public function extract(dest:String):Null<String> {
		var ret = null;
		final buf = Bytes.alloc(1 << 16); // 64 KB

		while (true) {
			final e = readEntryHeader();
			if (e == null) break;

			final size = e.fileSize;
			final path = Path.join([dest, e.fileName]);
			if (StringTools.endsWith(e.fileName, '/')) {
				if (ret == null) {
					ret = e.fileName;

					if (FileSystem.exists(path)) {
						// TODO: allow overwriting
						Sys.println('Output already exists; skipping');
						return ret;
					}
				}

				FileSystem.createDirectory(path);
			} else {
				final out = File.write(path, true);
				e.data = i.read(size);
				out.writeBytes(e.data, 0, size);
				out.close();
			}

			FileSync.chown(path, e.uid, e.gid);
			FileSync.chmod(path, [FileMode.NUMERIC(e.fmod)]);
			readPad(size);
		}

		return ret;
	}
}

class ZipExtractor {
	var i:Input;

	public function new(i:Input) {
		this.i = i;
	}

	public function extract(dest:String):Null<String> {
		var ret = null;
		final zip = try {
			final zip = haxe.zip.Reader.readZip(i);
			i.close();
			zip;
		} catch(e) {
			i.close();
			throw e;
		};

		for (e in zip) {
			final path = Path.join([dest, e.fileName]);

			if (StringTools.endsWith(e.fileName, '/')) {
				if (ret == null) {
					ret = e.fileName;

					if (FileSystem.exists(path)) {
						// TODO: allow overwriting
						Sys.println('Output already exists; skipping');
						return ret;
					}
				}

				FileSystem.createDirectory(path);
			} else {
				final out = File.write(path, true);
				out.writeBytes(haxe.zip.Reader.unzip(e), 0, e.fileSize);
				out.close();
			}
		}

		return ret;
	}
}
