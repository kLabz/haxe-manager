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
		// TODO: proper help message
		Sys.println("TODO help message");
	}
}
