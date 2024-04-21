package fuzzaldrin;

import haxe.Utf8;
import fuzzaldrin.Scorer;

typedef ResolvedCandidate<T> = {
	candidate:T,
	string:String,
	// TODO: highlighted string AST
	score:Score
}

typedef FilterOptions = {
	?key:String,
	?maxResults:Int
}

class Filter {

	static function pluckCandidates<T>(a:ResolvedCandidate<T>):T {
		return a.candidate;
	}

	@:haxe.warning("-WDeprecated")
	static function sortCandidates<T>(a:ResolvedCandidate<T>, b:ResolvedCandidate<T>):Int {
		if (b.score.score > a.score.score)
			return 1;
		else if (b.score.score < a.score.score)
			return -1;
		else
			return Utf8.compare(a.string, b.string);
	}

	public static function filterExt<T>(candidates:Array<T>, query:String, queryHasSlashes:Bool, ?options:FilterOptions):Array<ResolvedCandidate<T>> {
		var key:String = options != null ? options.key : null;
		var maxResults:Int = options != null && options.maxResults != null ? options.maxResults : -1;
		var hasQuery:Bool = (query != null && query.length > 0);
		var scoredCandidates:Array<ResolvedCandidate<T>> = [];

		for (i in 0...candidates.length) {
			var candidate = candidates[i];
			var string:String = key != null ? Reflect.getProperty(candidate, key) : cast candidate;
			if (string == null || string.length == 0) {
				continue;
			}
			var score = hasQuery ? Scorer.score(string, query) : {score: 1.0, parts: [RawString(string)]};
			// TODO
			// if (hasQuery && !queryHasSlashes) {
			// 	score = Scorer.basenameScore(string, query, score);
			// }
			if (score.score > 0) {
				scoredCandidates.push({
					candidate: candidate,
					string: string,
					score: score
				});
			}
		}

		if (hasQuery) scoredCandidates.sort(sortCandidates);

		if (maxResults != -1) {
			scoredCandidates = scoredCandidates.slice(0, maxResults);
		}

		return scoredCandidates;
	}

	public static function filter<T>(candidates:Array<T>, query:String, queryHasSlashes:Bool, ?options:FilterOptions):Array<T> {
		if (query == null || query.length == 0) return candidates;
		return filterExt(candidates, query, queryHasSlashes, options).map(pluckCandidates);
	}
}
