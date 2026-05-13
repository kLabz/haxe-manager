package tools;

import eval.luv.File.FileSync;
import haxe.io.Bytes;
import haxe.io.Eof;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import sys.io.FileOutput;

typedef ByteSource = {
	function readBytes(buf:Bytes, pos:Int, len:Int):Int;
}

class TarExtractor {
	static inline var BUFSIZE = 1 << 16; // 64 KB

	final src:ByteSource;
	final buf:Bytes;
	final header:Bytes;
	var bufPos:Int = 0;
	var bufLen:Int = 0;
	var eof:Bool = false;

	public function new(src:ByteSource) {
		this.src = src;
		this.buf = Bytes.alloc(BUFSIZE);
		this.header = Bytes.alloc(512);
	}

	function fill():Void {
		bufPos = 0;
		bufLen = 0;
		while (bufLen < BUFSIZE) {
			var n;
			try {
				n = src.readBytes(buf, bufLen, BUFSIZE - bufLen);
			} catch (_:Eof) {
				n = 0;
			}
			if (n <= 0) {
				if (bufLen == 0) eof = true;
				return;
			}
			bufLen += n;
		}
	}

	function readInto(dst:Bytes, dstPos:Int, n:Int):Bool {
		while (n > 0) {
			if (bufPos == bufLen) {
				fill();
				if (bufLen == 0) return false;
			}
			final avail = bufLen - bufPos;
			final take = n < avail ? n : avail;
			dst.blit(dstPos, buf, bufPos, take);
			bufPos += take;
			dstPos += take;
			n -= take;
		}
		return true;
	}

	function skipBytes(n:Int):Void {
		while (n > 0) {
			if (bufPos == bufLen) {
				fill();
				if (bufLen == 0) return;
			}
			final avail = bufLen - bufPos;
			final take = n < avail ? n : avail;
			bufPos += take;
			n -= take;
		}
	}

	function streamTo(out:FileOutput, n:Int):Void {
		while (n > 0) {
			if (bufPos == bufLen) {
				fill();
				if (bufLen == 0) throw "Unexpected EOF in tar stream";
			}
			final avail = bufLen - bufPos;
			final take = n < avail ? n : avail;
			out.writeBytes(buf, bufPos, take);
			bufPos += take;
			n -= take;
		}
	}

	function parseOctal(pos:Int, len:Int):Int {
		var v = 0;
		final end = pos + len;
		while (pos < end) {
			final c = header.get(pos);
			pos++;
			if (c == 0 || c == 32) continue;
			if (c < 48 || c > 55) break;
			v = (v << 3) + (c - 48);
		}
		return v;
	}

	function readCString(pos:Int, max:Int):String {
		var end = pos;
		final limit = pos + max;
		while (end < limit && header.get(end) != 0) end++;
		return header.getString(pos, end - pos);
	}

	public function extract(dest:String):Null<String> {
		var ret:Null<String> = null;
		while (true) {
			if (!readInto(header, 0, 512)) break;

			// Detect end-of-archive (zero block).
			var allZero = true;
			for (i in 0...512) if (header.get(i) != 0) { allZero = false; break; }
			if (allZero) break;

			final fname = readCString(0, 100);
			final fmod  = parseOctal(100, 8);
			final uid   = parseOctal(108, 8);
			final gid   = parseOctal(116, 8);
			final fsize = parseOctal(124, 12);

			final path = Path.join([dest, fname]);
			if (StringTools.endsWith(fname, '/')) {
				if (ret == null) {
					ret = fname;
					if (FileSystem.exists(path)) {
						// TODO: allow overwriting
						Sys.println('Output already exists; skipping');
						return ret;
					}
				}
				FileSystem.createDirectory(path);
			} else {
				final out = File.write(path, true);
				streamTo(out, fsize);
				out.close();
			}

			FileSync.chown(path, uid, gid);
			FileSync.chmod(path, [NUMERIC(fmod)]);

			final pad = ((fsize + 511) & ~511) - fsize;
			if (pad > 0) skipBytes(pad);
		}
		return ret;
	}
}
