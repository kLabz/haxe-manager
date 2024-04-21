class HaxeManager {
	public static function main() {
		Utils.wrap(() -> run(Sys.args()));
	}

	public static function run(args:Array<String>):Void {
		switch args.shift() {
			case null:
				var prompt = switch Utils.getCurrent() {
					case null | "": null;
					case v: 'Current: $v';
				};

				new fzf.Fzf(Utils.getVersions(), prompt, res -> {
					trace(res);
				});

			case "download": HaxeDownload.run(args);
			case "select": HaxeSelect.run(args);
			case "--help": displayUsage();
			case v: HaxeSelect.select(v);
		}
	}

	static function displayUsage() {
		// TODO: proper help message
		Sys.println("TODO help message");
	}
}
