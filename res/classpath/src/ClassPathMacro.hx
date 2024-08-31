import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.io.Path;
import sys.FileSystem;

class ClassPathMacro {
	public static function run() {
		var defines = Context.getDefines();
		var targets = ["js", "hl", "cpp", "cppia", "cs", "java", "jvm", "lua", "swf", "neko", "php", "python", "interp"];
		var target = first(defines.keys(), targets);
		Sys.println('[TARGET]: $target');
		Sys.println('[OUT]: ${Compiler.getOutput()}');

		var ownPath = FileSystem.fullPath(Path.join([Context.resolvePath("ClassPathMacro.hx"), '..']));

		for (cp in haxe.macro.Context.getClassPath()) {
			if (cp == "") continue;
			if (FileSystem.fullPath(cp) == ownPath) continue;
			Sys.println('[CLASSPATH]: $cp');
		}

		haxe.macro.Context.fatalError('Compilation aborted', haxe.macro.Context.currentPos());
	}

	static function first(defines:Iterator<String>, targets:Array<String>) {
		for (def in defines) if (targets.contains(def)) return def;
		return null;
	}
}
