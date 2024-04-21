package fuzzaldrin;

class Fuzzaldrin {

	public static var PATH_SEPARATOR = '/';

	public static var RE_SPACE = ~/%s/;

	public static function filter<T>(candidates:Array<T>, query:String, ?options:{
		?key:String,
		?maxResults:Int
	}):Array<T> {
		var queryHasSlashes = false;
		if (query != null && query.length > 0) {
			queryHasSlashes = query.indexOf(PATH_SEPARATOR) != -1;
			query = RE_SPACE.replace(query, '');
		}
		return Filter.filter(candidates, query, queryHasSlashes, options);
	}

	public static function score(string:String, query:String):Float {
		if (string == null || string.length == 0) {
			return 0;
		}
		if (query == null || query.length == 0) {
			return 0;
		}
		if (string == query) {
			return 2;
		}
		var queryHasSlashes = query.indexOf(PATH_SEPARATOR) != -1;
		query = RE_SPACE.replace(query, '');
		var score = Scorer.score(string, query);
		if (!queryHasSlashes) {
			score = Scorer.basenameScore(string, query, score);
		}
		return score;
	}

	function match(string:String, query:String) {
		if (string == null || string.length == 0) {
			return [];
		}
		if (query == null || query.length == 0) {
			return [];
		}
		if (string == query) {
			var results = [];
			for (i in 0...string.length) {
				results.push(i);
			}
			return results;
		}
		var queryHasSlashes = query.indexOf(PATH_SEPARATOR) != -1;
		query = RE_SPACE.replace(query, '');
		var matches = Matcher.match(string, query);
		if (!queryHasSlashes) {
			var baseMatches = Matcher.basenameMatch(string, query);
			matches = matches.concat(baseMatches);
			matches.sort(sortMatches);
			var seen = -1;
			var index = 0;
			while (index < matches.length) {
				if (index != 0 && seen == matches[index]) {
					matches.splice(index, 1);
                }
                else {
					seen = matches[index];
					index++;
				}
			}
		}
		return matches;
	}

	static function sortMatches(a:Int, b:Int):Int {
		if (a > b)
			return 1;
		else if (a < b)
			return -1;
		else
			return 0;
	}

}
