class HaxeSelect {
	public static function main() {
		Utils.wrap(() -> run(Sys.args()));
	}

	public static function run(args:Array<String>):Void {
		switch args {
			case [v]:
				if (Utils.hasVersion(v)) Utils.selectVersion(v, true);
				else Utils.selectRelease(v);

				Sys.println('Switched to $v');
				Sys.command("haxe", ["-version"]);

			case _: displayUsage();
		}
	}

	static function displayUsage() {
		// TODO: proper help message
		Sys.println("Please specify a haxe version");
	}
}
