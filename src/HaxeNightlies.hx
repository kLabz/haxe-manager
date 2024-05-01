import haxelib.SemVer;
import sys.io.Process;
import sys.FileSystem;

class HaxeNightlies {
	static var updated:Bool = false;
	static inline var ROOT = "data";
	static inline var HAXE_REPO = "https://github.com/HaxeFoundation/haxe.git";
	static var ref_check = ~/^[a-f0-9]{7,}$/i;

	public static function resolve(ref:String):String {
		if (SemVer.isValid(ref)) return getNightly(ref, true);
		if (isValid(ref)) return getNightly(ref);
		return ref;
	}

	public static function isValid(ref:String):Bool {
		return ref_check.match(ref);
	}

	static function getNightly(ref:String, ?isTag:Bool = false):Null<String> {
		final date = getCommitDate(ref);
		if (date == null) {
			if (!updated) {
				updateNightliesData();
				return getNightly(ref, isTag);
			} else {
				throw 'Cannot find Haxe revision $ref';
			}
		} else if (isTag) {
			return '${date}_refs/tags/${ref}_${getShortSha(ref)}';
		} else {
			if (!checkBranch(ref)) throw 'Only revisions from branch development are supported atm';
			return '${date}_development_${getShortSha(ref)}';
		}
	}

	static function git(args:Array<String>, ?dir:String):String {
		if (dir != null) args = ["--git-dir", ROOT].concat(args);
		args.push("--quiet");

		final proc = new Process("git", args);
		try {
			final code = proc.exitCode();
			if (code > 0) throw proc.stderr.readAll().toString();
			final ret = StringTools.trim(proc.stdout.readAll().toString());
			proc.close();
			return ret == "" ? null : ret;
		} catch (e) {
			proc.close();
			throw e;
		}
	}

	// Returns true if freshly setup
	static function ensureSetup():Bool {
		if (FileSystem.exists(ROOT)) return false;

		Sys.println("Initialize nightlies data...");
		git(["clone", "--bare", HAXE_REPO, ROOT]);
		Sys.println("Nightlies data ready.");

		return true;
	}

	static function updateNightliesData() {
		if (!ensureSetup()) {
			Sys.println("Updating nightlies data...");
			git(["fetch", HAXE_REPO, "development:development"], ROOT);
		}
		updated = true;
	}

	static function getCommitDate(ref:String):Null<String> {
		try {
			Sys.putEnv("TZ", "UTC");
			return git(["show", "--date", "format-local:%Y-%m-%d", "--format=%cd", ref], ROOT);
		} catch (e:String) {
			// trace(e);
			return null;
		}
	}

	static function getShortSha(ref:String):String {
		final full = git(["rev-parse", ref], ROOT);
		return full.substr(0, 7);
	}

	static function checkBranch(ref:String):Bool {
		try {
			return git(["branch", "development", "--contains", ref], ROOT) != null;
		} catch (e:String) {
			// trace(e);
			return false;
		}
	}
}
