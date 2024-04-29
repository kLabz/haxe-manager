package fzf;

enum WordNavResult {
	Noop;
	EOF;
	NavTo(i:Int);
}

class WordNav {
	public static function navLeft(cursor:Int, s:String):WordNavResult {
		if (cursor == 0 || s.length == 0) return Noop;

		var done = false;
		var wordStarted = false;

		for (i in 0...cursor) {
			final ii = cursor - i - 1;
			final c = s.charCodeAt(ii);

			if (c >= 48 && c <= 57) wordStarted = true;
			else if (c >= 65 && c <= 90) wordStarted = true;
			else if (c >= 97 && c <= 122) wordStarted = true;
			else if (!wordStarted) continue;
			else return NavTo(ii + 1);
		}

		return EOF;
	}

	public static function navRight(cursor:Int, s:String):WordNavResult {
		if (cursor >= s.length || s.length == 0) return Noop;

		var done = false;
		var wordStarted = false;

		for (i in cursor...s.length) {
			final c = s.charCodeAt(i);

			if (c >= 48 && c <= 57) wordStarted = true;
			else if (c >= 65 && c <= 90) wordStarted = true;
			else if (c >= 97 && c <= 122) wordStarted = true;
			else if (!wordStarted) continue;
			else return NavTo(i + 1);
		}

		return EOF;
	}
}
