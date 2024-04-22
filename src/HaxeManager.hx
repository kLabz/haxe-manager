import tools.Utils;

import ansi.ANSI;

using tools.NullTools;

class HaxeManager {
	public static function main() {
		Utils.wrap(() -> run(Sys.args()));
	}

	public static function run(args:Array<String>):Void {
		switch [args.shift(), args] {
			case [null, _]: HaxeSelect.fzf();
			case ["download", args]: HaxeDownload.run(args);
			case ["select", args]: HaxeSelect.run(args);

			case ["current", []]: Sys.println(Utils.getCurrent().or(""));
			case ["current", ["--name"]]:
				if (Sys.systemName() == "Windows")
					throw "`hx current --name` is not supported on windows";

				Sys.println(Utils.getCurrentName().or(""));

			case ["current", ["--full"]]:
				if (Sys.systemName() == "Windows")
					throw "`hx current --full` is not supported on windows";

				Sys.println(Utils.getCurrentFull().or(""));

			case ["list", []]: for (v in Utils.getVersions()) Sys.println(v);

			case ["--help", []]: displayUsage();
			case ["--help", ["download"]]: HaxeDownload.displayUsage();
			case ["--help", ["select"]]: HaxeSelect.displayUsage();

			case [v, []]: HaxeSelect.select(v);
			case _: throw 'Invalid arguments';
		}
	}

	static function displayUsage() {
		var ORANGE = ANSI.CSI + '38;5;208m';
		var RESET = ANSI.set(Off);
		var UNDERLINE = ANSI.set(Underline);
		var UNDERLINE_OFF = ANSI.set(UnderlineOff);
		var BOLD = ANSI.set(Bold);
		var BOLD_OFF = ANSI.set(BoldOff);

		Sys.println([
			'${ORANGE}hx - Haxe Manager cli tool${RESET}',
			'${UNDERLINE}https://github.com/kLabz/haxe-manager${UNDERLINE_OFF}',
			'',
			'Usage: ${ORANGE}hx${RESET}',
			'       Interactive version switcher for versions available locally',
			'',
			'   or: ${ORANGE}hx download ${UNDERLINE}<VERSION>${UNDERLINE_OFF} ${UNDERLINE}[AS_NAME]${RESET}',
			'   or: ${ORANGE}hx download nightly ${UNDERLINE}<VERSION>${UNDERLINE_OFF} ${UNDERLINE}[AS_NAME]${RESET}',
			'   or: ${ORANGE}hx download latest ${UNDERLINE}[AS_NAME]${RESET}',
			'       Install Haxe releases or nightlies',
			'',
			'   or: ${ORANGE}hx ${UNDERLINE}<VERSION>${RESET}',
			'   or: ${ORANGE}hx select ${UNDERLINE}<VERSION>${RESET}',
			'       Switch to installed Haxe version ${BOLD}VERSION${BOLD_OFF}',
			'',
			'   or: ${ORANGE}hx current${RESET}',
			'   or: ${ORANGE}hx current --name${RESET}',
			'   or: ${ORANGE}hx current --full${RESET}',
			'       Display current Haxe version string',
			'       ${BOLD}--name${BOLD_OFF} will display the name under which this version has been installed',
			'       ${BOLD}--full${BOLD_OFF} will display both name and version string',
			'',
			'   or: ${ORANGE}hx list${RESET}',
			'       Display all installed Haxe versions',
			'',
			'   or: ${ORANGE}hx --help${RESET}',
			'   or: ${ORANGE}hx --help download${RESET}',
			'   or: ${ORANGE}hx --help select${RESET}',
			'       Display help about available commands'
		].join("\n"));
	}
}
