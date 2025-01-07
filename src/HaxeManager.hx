import ansi.ANSI;
import tools.Utils;

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

			// Lix related commands
			case ["rc", []]: LixTools.resolveHaxe();
			case ["rc", ["update"]]: LixTools.updateHaxeRc();
			case ["rc", ["filename"]]: Sys.println(LixTools.getFilename());
			case ["lix-to-install", [file]]: LixTools.generateInstallHxml(file);
			case ["lix-libs", []]: LixTools.applyLibs();

			case ["install", [file]]: HaxeDownload.installLocal(file);
			case ["install", [file, alias]]: HaxeDownload.installLocal(file, alias);

			case ["current", []]: Sys.println(Utils.getCurrent().or(""));
			case ["current", ["--name"]]:
				if (Sys.systemName() == "Windows")
					throw "`hx current --name` is not supported on Windows";

				Sys.println(Utils.getCurrentName().or(""));

			case ["current", ["--full"]]:
				if (Sys.systemName() == "Windows")
					throw "`hx current --full` is not supported on Windows";

				Sys.println(Utils.getCurrentFull().or(""));

			case ["current", ["--sha"]]:
				if (Sys.systemName() == "Windows")
					throw "`hx current --sha` is not supported on Windows";

				Sys.println(HaxeNightlies.resolveSha(Utils.getCurrentSha()).or(""));

			case ["list", []]: for (v in Utils.getVersions()) Sys.println(v);
			case ["list-classpath", []]: HaxeClasspath.list();
			case ["list-classpath", [hxml]]: HaxeClasspath.list(hxml);
			case ["list-modules", []]: HaxeClasspath.listModules();
			case ["list-modules", [hxml]]: HaxeClasspath.listModules(hxml);

			case ["dap-config", []]: HaxeClasspath.getDapConfig();
			case ["dap-config", [hxml]]: HaxeClasspath.getDapConfig(hxml);

			case ["--help", []]: displayUsage();
			case ["--help", ["download"]]: HaxeDownload.displayUsage();
			case ["--help", ["select"]]: HaxeSelect.displayUsage();

			// Experimental commands

			// Note: this is not suited for eval (or -cmd) using stdin, as that
			// will not be forwarded properly
			case ["with", args] if (args.length > 0):
				var v = args.shift();
				if (v == "rc") v = LixTools.getRc();
				final path = Utils.find(v);
				if (path == null) throw 'Version $v is not installed';
				Utils.runHaxe(path, args);

			// Internal commands
			case ["bundled", []]: Sys.println(BundledHaxe.getBundledVersion());
			case ["bundle", [version]]: BundledHaxe.setBundledVersion(version);

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

		var lines = [
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
			'   or: ${ORANGE}hx install ${UNDERLINE}<FILE>${UNDERLINE_OFF} ${UNDERLINE}[AS_NAME]${RESET}',
			'       Install Haxe release archive',
			'',
			'   or: ${ORANGE}hx ${UNDERLINE}<VERSION>${RESET}',
			'   or: ${ORANGE}hx select ${UNDERLINE}<VERSION>${RESET}',
			'       Switch to installed Haxe version ${BOLD}VERSION${BOLD_OFF}',
			'',
		];

		if (Sys.systemName() == "Windows") {
			lines = lines.concat([
				'   or: ${ORANGE}hx current${RESET}',
				'       Display current Haxe version string',
				'',
			]);
		} else {
			lines = lines.concat([
				'   or: ${ORANGE}hx current${RESET}',
				'   or: ${ORANGE}hx current --name${RESET}',
				'   or: ${ORANGE}hx current --full${RESET}',
				'       Display current Haxe version string',
				'       ${BOLD}--name${BOLD_OFF} will display the name under which this version has been installed',
				'       ${BOLD}--full${BOLD_OFF} will display both name and version string',
				'',
			]);
		}

		lines = lines.concat([
			'   or: ${ORANGE}hx rc${RESET}',
			'       Install and select Haxe version specified by .haxerc file',
			'',
			'   or: ${ORANGE}hx lix-libs${RESET}',
			'       Install libraries as specified by lix in haxe_libraries folder',
			'',
			'   or: ${ORANGE}hx lix-to-install ${UNDERLINE}<install.hxml>${RESET}',
			'       Generate installation instruction for haxelib in ${BOLD}install.hxml${BOLD_OFF}',
			'       from lix data in haxe_libraries folder',
			'',
			'   or: ${ORANGE}hx list${RESET}',
			'       Display all installed Haxe versions',
			'',
			'   or: ${ORANGE}hx --help${RESET}',
			'   or: ${ORANGE}hx --help download${RESET}',
			'   or: ${ORANGE}hx --help select${RESET}',
			'       Display help about available commands'
		]);

		Sys.println(lines.join("\n"));
	}
}
