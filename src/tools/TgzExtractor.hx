package tools;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import haxe.io.Input;
import haxe.zip.InflateImpl;
import format.gz.Reader as GzReader;
import format.tgz.Reader as TgzReader;

class TgzExtractor extends TgzReader {
	public function extract(dest:String):Null<String> {
		try {
			final tmp = new BytesOutput();
			final gz = new GzReader(i);
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
