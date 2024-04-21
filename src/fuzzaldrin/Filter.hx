package fuzzaldrin;

import haxe.Utf8;

class Filter {

	static function pluckCandidates(a):Dynamic {
		return a.candidate;
	}

	@:haxe.warning("-WDeprecated")
	static function sortCandidates(a:{
		candidate:Dynamic,
		string:String,
		score:Float
	}, b:{
		candidate:Dynamic,
		string:String,
		score:Float
	}):Int {
		if (b.score > a.score)
			return 1;
		else if (b.score < a.score)
			return -1;
		else
			return Utf8.compare(a.string, b.string);
	}

	public static function filter<T>(candidates:Array<T>, query:String, queryHasSlashes:Bool, ?options:{
		?key:String,
		?maxResults:Int
	}):Array<T> {
		var key:String = options != null ? options.key : null;
		var maxResults:Int = options != null && options.maxResults != null ? options.maxResults : -1;
		if (query != null && query.length > 0) {
			var scoredCandidates:Array<{
				candidate:Dynamic,
				string:String,
				score:Float
			}> = [];
			for (i in 0...candidates.length) {
				var candidate:Dynamic = candidates[i];
				var string:String = key != null ? Reflect.getProperty(candidate, key) : candidate;
				if (string == null || string.length == 0) {
					continue;
				}
				var score = Scorer.score(string, query);
				if (!queryHasSlashes) {
					score = Scorer.basenameScore(string, query, score);
				}
				if (score > 0) {
					scoredCandidates.push({
						candidate: candidate,
						string: string,
						score: score
					});
				}
			}
			scoredCandidates.sort(sortCandidates);
			candidates = scoredCandidates.map(pluckCandidates);
		}
		if (maxResults != -1) {
			candidates = candidates.slice(0, maxResults);
		}
		return candidates;
    }

}
