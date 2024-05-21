package fzf;

import eval.luv.File;
import eval.luv.Loop;
import eval.luv.Tty;
import haxe.ds.Option;

import ansi.ANSI;
import fuzzaldrin.Filter;
import fuzzaldrin.Scorer;
import fzf.WordNav;

typedef FzfOptions = {
	@:optional var prompt:String;
	@:optional var geom:{width:Int, height:Int};
}

class Fzf {
	final items:Array<String>;
	final cb:Option<String>->Void;
	final prompt:String;
	final strippedPrompt:String;
	final tty:Tty;
	final options:FzfOptions;

	var scroll:Int = 0;
	var cursor:Int = 0;
	var currentItem:Int = 0;
	var currentFilter:String = "";
	var filteredItems:Array<ResolvedCandidate<String>> = [];

	static inline var CTRL_A = 1;
	static inline var CTRL_B = 2;
	static inline var CTRL_C = 3;
	static inline var CTRL_E = 5;
	static inline var CTRL_F = 6;
	static inline var CTRL_H = 8;
	static inline var CTRL_J = 10;
	static inline var CTRL_K = 11;
	static inline var CTRL_N = 14;
	static inline var CTRL_P = 16;
	static inline var CTRL_Q = 17;
	static inline var CTRL_U = 21;
	static inline var CTRL_W = 23;

	static inline var ENTER = 13;
	static inline var ESC = 27;
	static inline var LEFT_BRACKET = 91;
	static inline var BACKSPACE = 127;
	static inline var DELETE = 126;

	static inline var ARROW_UP = 65;
	static inline var ARROW_DOWN = 66;
	static inline var ARROW_RIGHT = 67;
	static inline var ARROW_LEFT = 68;

	// Additional ANSI escape codes
	// See https://stackoverflow.com/questions/4842424/list-of-ansi-color-escape-sequences
	// TODO: detect support!
	// static inline var LightBlue = ANSI.CSI + '94m';
	static inline var LightBlue = ANSI.CSI + '38;5;111m';
	static inline var LightGreen = ANSI.CSI + '38;5;108m';
	static inline var LighterGreen = ANSI.CSI + '38;5;144m';
	static inline var Grey = ANSI.CSI + '38;5;241m';
	static inline var GreyBack = ANSI.CSI + '48;5;236m';

	static function defaultOptions():FzfOptions {
		return {};
	}

	public function new(items:Array<String>, ?options:FzfOptions, cb:Option<String>->Void) {
		this.items = items;
		this.cb = cb;
		this.options = options ?? defaultOptions();
		this.filteredItems = items.map(i -> {
			candidate: i,
			string: i,
			score: {
				score: 1.0,
				parts: [RawString(i)]
			}
		});

		// TODO: strip sequences in prompt input?
		var prompt = options.prompt ?? "";
		this.strippedPrompt = (prompt == "" ? "" : prompt + " ") + "> ";
		this.prompt = ANSI.set(Bold) + LightBlue + this.strippedPrompt + ANSI.set(Off);

		// TODO: find a way to have a proper _new_ tty
		if (options.geom == null) this.tty = Tty.init(Loop.defaultLoop(), File.stderr).resolve();

		var esc = [];
		while (true) {
			redraw();

			var ch = Sys.getChar(false);
			switch [esc, ch] {
				case [[], CTRL_A]:
					cursor = 0;

				case [[], CTRL_U]:
					cursor = 0;
					currentFilter = "";
					updateFilter();

				case [[], CTRL_E]:
					cursor = currentFilter.length;

				case [[], CTRL_C] | [[], CTRL_Q]:
					return exitWith(None);

				case [[], CTRL_W]:
					switch WordNav.navLeft(cursor, currentFilter) {
						case Noop:
						case EOF:
							currentFilter = currentFilter.substring(cursor);
							cursor = 0;
							updateFilter();
						case NavTo(i):
							currentFilter = currentFilter.substring(0, i) + currentFilter.substring(cursor);
							cursor = i;
							updateFilter();
					}

				case [[], DELETE]:
					if (currentFilter.length > 0) {
						currentFilter = currentFilter.substring(0, cursor) + currentFilter.substr(cursor + 1);
						updateFilter();
					}

				case [[], BACKSPACE] | [[], CTRL_H]:
					if (cursor > 0 && currentFilter.length > 0) {
						currentFilter = currentFilter.substring(0, cursor - 1) + currentFilter.substr(cursor);
						cursor--;
						updateFilter();
					}

				case [_, ESC]:
					esc = [ESC];

				case [[], ENTER]:
					if (filteredItems.length == 0) return exitWith(None);
					return exitWith(Some(filteredItems[currentItem].candidate));

				case [[ESC], LEFT_BRACKET]:
					esc = [ESC, LEFT_BRACKET];

				case [[ESC], ch]:
					// trace(esc, ch);
					esc = [ESC, ch];

				case [[ESC, LEFT_BRACKET, 49, 59, 53], ARROW_LEFT]:
					switch WordNav.navLeft(cursor, currentFilter) {
						case Noop:
						case EOF: cursor = 0;
						case NavTo(i): cursor = i;
					}
					esc = [];

				case [[ESC, LEFT_BRACKET, 49, 59, 53], ARROW_RIGHT]:
					switch WordNav.navRight(cursor, currentFilter) {
						case Noop:
						case EOF: cursor = currentFilter.length;
						case NavTo(i): cursor = i;
					}
					esc = [];

				case [[ESC, LEFT_BRACKET], ARROW_LEFT] | [[], CTRL_B]:
					if (cursor > 0) cursor--;
					esc = [];

				case [[ESC, LEFT_BRACKET], ARROW_RIGHT] | [[], CTRL_F]:
					if (cursor < currentFilter.length) cursor++;
					esc = [];

				case [[ESC, LEFT_BRACKET], ARROW_UP] | [[], CTRL_K] | [[], CTRL_P]:
					if (currentItem < filteredItems.length - 1) currentItem++;
					esc = [];

				case [[ESC, LEFT_BRACKET], ARROW_DOWN] | [[], CTRL_J] | [[], CTRL_N]:
					if (currentItem > 0) currentItem--;
					esc = [];

				case [[ESC, LEFT_BRACKET], 49]: esc.push(49);
				case [[ESC, LEFT_BRACKET, 49], 59]: esc.push(59);
				case [[ESC, LEFT_BRACKET, 49, 59], 53]: esc.push(53);
				// TODO?
				case [[ESC, LEFT_BRACKET, 49, 59, 53], _]: esc = [];

				case [[ESC, _], ch]:
					// TODO?
					// trace(esc, ch);
					esc = [];

				case [[], ch]:
					currentFilter = currentFilter.substring(0, cursor) + String.fromCharCode(ch) + currentFilter.substr(cursor);
					cursor++;
					updateFilter();

				case [esc, ch]:
					// TODO?
					// trace(esc, ch);
					esc = [];
			}
		}
	}

	function redraw():Void {
		var screen = "";
		final geom = options.geom ?? tty.getWinSize().resolve();
		final height = geom.height - 2;
		final hasScroll = height < filteredItems.length;

		if (hasScroll) {
			if (currentItem - scroll >= height) scroll = currentItem - height + 1;
			else if (currentItem < scroll) scroll = currentItem;
		} else {
			scroll = 0;
		}

		final scrollStart = hasScroll ? Math.round((scroll / filteredItems.length) * height) : 0;
		final scrollEnd = hasScroll ? Math.round(((scroll+height-1) / filteredItems.length) * height) : 0;

		for (i in 0...height) {
			var line = ANSI.setXY(0, height - i);
			final index = i + scroll;

			if (index >= filteredItems.length) {
				if (hasScroll) {
					line += ANSI.insertChars(geom.width - 1);
					line += (scrollStart <= i && i <= scrollEnd) ? '-' : ':';
				} else {
					line += ANSI.insertChars(geom.width);
				}

				screen += line;
				continue;
			}

			var item = filteredItems[index];
			var itemRepr = "";
			for (p in item.score.parts) {
				switch (p) {
					case RawString(s): itemRepr += s;
					case MatchedString(s): itemRepr += LightGreen + s + ANSI.set(DefaultForeground);
				}
			}

			if (index == currentItem)
				line += GreyBack + ANSI.set(Red) + "> " + ANSI.set(Off) + ANSI.set(Bold) + GreyBack + itemRepr + ANSI.set(Off);
			else
				line += GreyBack + " " + ANSI.set(Off) + " " + itemRepr;

			line += ANSI.eraseLineToEnd();
			if (hasScroll) {
				line += ANSI.setX(geom.width);
				line += (scrollStart <= i && i <= scrollEnd) ? ANSI.set(Bold) + Grey + '│' + ANSI.set(Off) : ' ';
			}

			screen += line;
		}

		screen += ANSI.setXY(0, geom.height - 1);
		final index = "  " + filteredItems.length + '/' + items.length + " ";
		final pad = [for (_ in (index.length)...(geom.width-1)) '―'].join("");
		screen += LighterGreen + index + Grey + ANSI.set(Bold) + pad + ANSI.set(Off);

		screen += ANSI.setXY(0, geom.height);
		screen += prompt + currentFilter + ANSI.eraseLineToEnd();

		screen += ANSI.setX(cursor + strippedPrompt.length + 1); // Why +1 here?
		Sys.print(screen);
	}

	function exitWith(value:Option<String>) {
		// See https://github.com/libuv/libuv/issues/257
		Sys.print(ANSI.setX(0));
		Sys.print(ANSI.eraseLine());
		cb(value);
	}

	function updateFilter():Void {
		filteredItems = Filter.filterExt(items, currentFilter, false);
		currentItem = 0;
		scroll = 0;
	}
}
