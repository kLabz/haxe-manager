package tools;

import haxe.io.Bytes;
import haxe.io.Input;
import haxe.zip.Uncompress;

class TgzExtractor {
	final i:Input;

	public function new(i:Input) {
		this.i = i;
	}

	public function extract(dest:String):Null<String> {
		try {
			final src = i.readAll();
			i.close();
			return new TarExtractor(new GzInflate(src)).extract(dest);
		} catch (e) {
			i.close();
			throw e;
		}
	}
}

private class GzInflate {
	final src:Bytes;
	final u:Uncompress;
	var srcPos:Int = 0;
	var done:Bool = false;

	public function new(src:Bytes) {
		this.src = src;
		this.u = new Uncompress(15 + 32);
	}

	public function readBytes(buf:Bytes, pos:Int, len:Int):Int {
		if (done) return 0;
		var written = 0;
		while (written < len) {
			final r = u.execute(src, srcPos, buf, pos + written);
			srcPos += r.read;
			written += r.write;
			if (r.done) { done = true; break; }
			if (r.read == 0 && r.write == 0) break; // need more output room
		}
		return written;
	}
}
