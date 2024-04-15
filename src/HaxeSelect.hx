class HaxeSelect {
	public static function main() {
		trace("hx-select");
		switch Sys.args() {
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
