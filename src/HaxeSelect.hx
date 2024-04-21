import fzf.Fzf;
import tools.Utils;

using tools.NullTools;

class HaxeSelect {
	public static function main() {
		Utils.wrap(() -> run(Sys.args()));
	}

	public static function run(args:Array<String>):Void {
		switch args {
			case [v]: select(v);
			case _: displayUsage();
		}
	}

	public static function fzf():Void {
		final prompt = 'Current: ' + Utils.getCurrentName().or(Utils.getCurrent().or('none'));

		new Fzf(Utils.getVersions(), prompt, res -> {
			switch res {
				case None: Sys.println('No Haxe version selected');
				case Some(v): select(v);
			}
		});

	}

	public static function select(v:String):Void {
		if (Utils.hasVersion(v)) Utils.selectVersion(v, true);
		else Utils.selectRelease(v);

		Sys.println('Switched to $v');
		Sys.command("haxe", ["-version"]);
	}

	public static function displayUsage() {
		// TODO: proper help message
		Sys.println("Please specify a haxe version");
	}
}
