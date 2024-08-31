import haxe.io.Path;
import sys.FileSystem;
import sys.io.Process;

import tools.Utils;

using StringTools;

typedef ClasspathResult = {
	var target:String;
	var cwd:String;
	var out:String;
	var classpath:Array<String>;
}

class HaxeClasspath {
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

	static var stdRoot = FileSystem.fullPath(Path.join([Sys.getCwd(), "current", "std"]));

	static function getClasspath(?hxml:String = "build.hxml", ?fullpath:Bool = false):ClasspathResult {
		final cwd = Utils.getCallSite();
		hxml = Path.isAbsolute(hxml) ? hxml : Path.join([cwd, hxml]);
		if (!FileSystem.exists(hxml)) throw 'Cannot find hxml file $hxml';

		Sys.putEnv("HAXE_STD_PATH", stdRoot);
		final args = [
			"--cwd", cwd,
			hxml,
			"-cp", FileSystem.absolutePath("res/classpath/src"),
			"--macro", "ClassPathMacro.run()",
			"--no-output"
		];
		if (fullpath) {
			args.push("-D");
			args.push("fullpath");
		}
		final proc = new Process("haxe", args);

		try {
			final code = proc.exitCode();
			final out = proc.stdout.readAll().toString();
			proc.close();

			var output:Null<String> = null;
			var target:Null<String> = null;
			var classpath:Array<String> = [];

			final targetPrefix = "[TARGET]: ";
			final cpPrefix = "[CLASSPATH]: ";
			final outPrefix = "[OUT]: ";

			for (l in out.split("\n")) {
				if (l.startsWith(targetPrefix)) {
					target = l.substr(targetPrefix.length);
				} else if (l.startsWith(cpPrefix)) {
					var cp = l.substr(cpPrefix.length);
					classpath.push(cp);
				} else if (l.startsWith(outPrefix)) {
					output = l.substr(outPrefix.length);
				}
			}

			return {
				target: target,
				cwd: cwd,
				out: output,
				classpath: classpath
			};
		} catch (e) {
			Utils.displayError(Std.string(e));
			proc.close();
			throw e;
		}
	}

	static function extractTargetStd(cwd:String, cp:String):Array<String> {
		var path = FileSystem.fullPath(Path.isAbsolute(cp) ? cp : Path.join([cwd, cp]));
		if (!path.startsWith(stdRoot)) return [cp, null];

		cp = path; // Use resolved path for std
		var path = cp.substr(stdRoot.length);
		path = StringTools.replace(path, '\\', '/');
		while (path.charCodeAt(0) == '/'.code) path = path.substr(1);
		return [cp, path.split('/').shift()];
	}

	public static function list(?hxml:String = "build.hxml"):Void {
		try {
			var data = getClasspath(hxml);
			for (cp in data.classpath) {
				Sys.println(cp);
			}
		} catch (e) {
			Utils.displayError(Std.string(e));
		}
	}

	public static function getDapConfig(?hxml:String = "build.hxml"):Void {
		try {
			var data = getClasspath(hxml, true);
			Sys.println([
				'{',
				'	name="HashLink",',
				'	request="launch",',
				'	type="hl",',
				'	cwd="${data.cwd}",',
				'	classPaths={${data.classpath.map(cp -> "\'" + cp + "\'").join(", ")}},',
				'	program="${data.out}"',
				'}'
			].join('\n'));
		} catch (e) {
			Utils.displayError(Std.string(e));
		}
	}

	public static function listModules(?hxml:String = "build.hxml"):Void {
		try {
			var data = getClasspath(hxml);
			final old = Sys.getCwd();
			Sys.setCwd(data.cwd);

			function findModules(path:String) {
				if (Path.extension(path) == "hx") return Sys.println(path);
				if (!FileSystem.isDirectory(path)) return;

				path = Path.addTrailingSlash(path);
				for (f in FileSystem.readDirectory(path)) findModules(path + f);
			}

			var ignoredTargets = [];
			if (data.target != null) {
				if (data.target != "java" && data.target != "jvm") ignoredTargets = ignoredTargets.concat(["java", "jvm"]);
				if (data.target != "cpp" && data.target != "cppia") ignoredTargets.push("cpp");
				if (data.target != "js") ignoredTargets.push("js");
				if (data.target != "hl") ignoredTargets.push("hl");
				if (data.target != "cs") ignoredTargets.push("cs");
				if (data.target != "lua") ignoredTargets.push("lua");
				if (data.target != "neko") ignoredTargets.push("neko");
				if (data.target != "php") ignoredTargets.push("php");
				if (data.target != "python") ignoredTargets.push("python");
				if (data.target != "swf") ignoredTargets.push("flash");
			}

			for (cp in data.classpath) {
				switch extractTargetStd(data.cwd, cp) {
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
		}
	}
}
