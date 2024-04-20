package tools;

import haxe.io.Input;
import haxe.io.Path;
import haxe.zip.Reader;
import sys.FileSystem;
import sys.io.File;

class ZipExtractor {
	var i:Input;

	public function new(i:Input) {
		this.i = i;
	}

	public function extract(dest:String):Null<String> {
		var ret = null;
		final zip = try {
			final zip = Reader.readZip(i);
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
				out.writeBytes(Reader.unzip(e), 0, e.fileSize);
				out.close();
			}
		}

		return ret;
	}
}
