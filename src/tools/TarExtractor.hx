package tools;

import eval.luv.File.FileSync;
import format.tar.Reader;
import haxe.io.Bytes;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

class TarExtractor extends Reader {
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
			FileSync.chmod(path, [NUMERIC(e.fmod)]);
			readPad(size);
		}

		return ret;
	}
}
