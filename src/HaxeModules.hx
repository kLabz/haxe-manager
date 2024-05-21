import haxe.io.Path;
import sys.FileSystem;
import sys.io.Process;

import tools.Utils;

using StringTools;

class HaxeModules {
	static var targets = [
		"js",
		"hl",
		"cpp",
		"cppia",
		"cs",
		"java",
		"jvm",
		"lua",
		"swf",
		"neko",
		"php",
		"python",
		"interp"
	];

	public static function listModules(?hxml:String = "build.hxml"):Void {
		final cwd = Utils.getCallSite();
		hxml = Path.isAbsolute(hxml) ? hxml : Path.join([cwd, hxml]);
		if (!FileSystem.exists(hxml)) throw 'Cannot find hxml file $hxml';

		final stdRoot = FileSystem.fullPath(Path.join([Sys.getCwd(), "current", "std"]));
		Sys.putEnv("HAXE_STD_PATH", stdRoot);
		final proc = new Process("haxe", [
			"--cwd", cwd,
			hxml,
			"-cp", FileSystem.absolutePath("res/classpath/src"),
			"--macro", "ClassPathMacro.run()",
			"--no-output"
		]);

		try {
			final code = proc.exitCode();
			final out = proc.stdout.readAll().toString();
			proc.close();

			var target:Null<String> = null;
			var classpath:Array<String> = [];
			final targetPrefix = "[TARGET]: ";
			final cpPrefix = "[CLASSPATH]: ";

			for (l in out.split("\n")) {
				if (l.startsWith(targetPrefix)) {
					target = l.substr(targetPrefix.length);
				} else if (l.startsWith(cpPrefix)) {
					var cp = l.substr(cpPrefix.length);
					classpath.push(cp);
				}
			}

			final old = Sys.getCwd();
			Sys.setCwd(cwd);

			function findModules(path:String) {
				if (Path.extension(path) == "hx") return Sys.println(path);
				if (!FileSystem.isDirectory(path)) return;

				path = Path.addTrailingSlash(path);
				for (f in FileSystem.readDirectory(path)) findModules(path + f);
			}

			function extractTargetStd(cp:String):Array<String> {
				var path = FileSystem.fullPath(Path.isAbsolute(cp) ? cp : Path.join([cwd, cp]));
				if (!path.startsWith(stdRoot)) return [cp, null];

				cp = path; // Use resolved path for std
				var path = cp.substr(stdRoot.length);
				path = StringTools.replace(path, '\\', '/');
				while (path.charCodeAt(0) == '/'.code) path = path.substr(1);
				return [cp, path.split('/').shift()];
			}

			var ignoredTargets = [];
			if (target != null) {
				if (target != "java" && target != "jvm") ignoredTargets = ignoredTargets.concat(["java", "jvm"]);
				if (target != "cpp" && target != "cppia") ignoredTargets.push("cpp");
				if (target != "js") ignoredTargets.push("js");
				if (target != "hl") ignoredTargets.push("hl");
				if (target != "cs") ignoredTargets.push("cs");
				if (target != "lua") ignoredTargets.push("lua");
				if (target != "neko") ignoredTargets.push("neko");
				if (target != "php") ignoredTargets.push("php");
				if (target != "python") ignoredTargets.push("python");
				if (target != "swf") ignoredTargets.push("flash");
			}

			for (cp in classpath) {
				switch extractTargetStd(cp) {
					// Non-std
					case [cp, null]: findModules(cp);

					// Top level std
					case [cp, ""]:
						cp = Path.addTrailingSlash(cp);
						var sub = FileSystem.readDirectory(cp);
						for (f in sub) {
							if (ignoredTargets.contains(f)) continue;
							findModules(cp + f);
						}

					case [_, t] if (ignoredTargets.contains(t)):
					case [cp, _]: findModules(cp);
				};
			}

			Sys.setCwd(old);
		} catch (e) {
			Utils.displayError(Std.string(e));
			proc.close();
		}
	}
}
