package fzf;

import eval.luv.File;
import eval.luv.Loop;
import eval.luv.Tty;
import haxe.ds.Option;

import ANSI;
import fuzzaldrin.Fuzzaldrin;

class Fzf {
	final items:Array<String>;
	final cb:Option<String>->Void;
	final prompt:String;
	final strippedPrompt:String;
	final tty:Tty;

	// TODO: scroll x_x
	var cursor:Int = 0;
	var currentItem:Int = 0;
	var currentFilter:String = "";
	var filteredItems:Array<String> = [];

	static inline var CTRL_A = 1;
	static inline var CTRL_B = 2;
	static inline var CTRL_C = 3;
	static inline var CTRL_E = 5;
	static inline var CTRL_F = 6;
	static inline var CTRL_H = 8;
	static inline var CTRL_J = 10;
	static inline var CTRL_K = 11;
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
	static inline var Grey = ANSI.CSI + '38;5;241m';
	static inline var GreyBack = ANSI.CSI + '48;5;236m';

	public function new(items:Array<String>, ?prompt:String = "", cb:Option<String>->Void) {
		this.items = items;
		this.cb = cb;
		this.filteredItems = items.copy();

		// TODO: strip sequences in prompt input?
		this.strippedPrompt = (prompt == "" ? "" : prompt + " ") + "> ";
		this.prompt = ANSI.set(Bold) + LightBlue + this.strippedPrompt + ANSI.set(Off);

		this.tty = Tty.init(Loop.defaultLoop(), File.stderr).resolve();

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
					if (currentFilter.length > 0) {
						trace("TODO: delete to start of word");
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
					return exitWith(Some(filteredItems[currentItem]));

				case [[ESC], LEFT_BRACKET]:
					esc = [ESC, LEFT_BRACKET];

				case [[ESC], ch]:
					// trace(esc, ch);
					esc = [ESC, ch];

				case [[ESC, LEFT_BRACKET], ARROW_LEFT] | [[], CTRL_B]:
					if (cursor > 0) cursor--;
					esc = [];

				case [[ESC, LEFT_BRACKET], ARROW_RIGHT] | [[], CTRL_F]:
					if (cursor < currentFilter.length - 1) cursor++;
					esc = [];

				case [[ESC, LEFT_BRACKET], ARROW_UP] | [[], CTRL_K]:
					currentItem++;
					if (currentItem >= filteredItems.length) currentItem = 0;
					esc = [];

				case [[ESC, LEFT_BRACKET], ARROW_DOWN] | [[], CTRL_J]:
					currentItem--;
					if (currentItem < 0) currentItem = filteredItems.length - 1;
					esc = [];

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
		Sys.print(ANSI.hideCursor());
		final geom = tty.getWinSize().resolve();

		for (i in 0...(geom.height - 2)) {
			Sys.print(ANSI.setXY(0, geom.height - 2 - i));
			if (i >= filteredItems.length) {
				Sys.print(ANSI.insertChars(geom.width));
				continue;
			}

			// TODO: (+ handle scroll) (+ scrollbar?) (+ highlight fuzzy)
			if (i == currentItem)
				Sys.print(GreyBack + ANSI.set(Red) + "> " + ANSI.set(Off) + ANSI.set(Bold) + GreyBack + filteredItems[i] + ANSI.set(Off));
			else
				Sys.print(GreyBack + " " + ANSI.set(Off) + " " + filteredItems[i]);

			Sys.print(ANSI.eraseLineToEnd());
		}

		Sys.print(ANSI.setXY(0, geom.height - 1));
		final index = "  " + filteredItems.length + '/' + items.length + " ";
		final pad = [for (_ in (index.length)...(geom.width-1)) '―'].join("");
		Sys.print(Grey + index + ANSI.set(Bold) + pad + ANSI.set(Off));

		Sys.print(ANSI.setXY(0, geom.height));
		Sys.print(prompt + currentFilter + ANSI.eraseLineToEnd());

		Sys.print(ANSI.setX(cursor + strippedPrompt.length + 1)); // Why +1 here?
		Sys.print(ANSI.showCursor());
	}

	function exitWith(value:Option<String>) {
		// See https://github.com/libuv/libuv/issues/257
		Sys.print(ANSI.setX(0));
		Sys.print(ANSI.eraseLine());
		cb(value);
	}

	function updateFilter():Void {
		// TODO: need to rework that lib to:
		// 	- handle highlighting
		filteredItems = Fuzzaldrin.filter(items, currentFilter);
		currentItem = 0;
	}
}
