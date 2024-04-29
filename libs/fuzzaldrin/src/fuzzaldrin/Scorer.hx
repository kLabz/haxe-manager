package fuzzaldrin;

typedef Score = {
	score:Float,
	parts:Array<MatchPart>
}

enum MatchPart {
	RawString(s:String);
	MatchedString(s:String);
}

class Scorer {

	// TODO
	public static function basenameScore(string:String, query:String, score:Float):Float {
		var index = string.length - 1;
		while (string.charAt(index) == Fuzzaldrin.PATH_SEPARATOR) {
			index--;
		}
		var slashCount = 0;
		var lastCharacter = index;
		var base = null;
		while (index >= 0) {
			if (string.charAt(index) == Fuzzaldrin.PATH_SEPARATOR) {
				slashCount++;
				if (base == null) {
					base = string.substring(index + 1, lastCharacter + 1);
				}
			} else if (index == 0) {
				if (lastCharacter < string.length - 1) {
					if (base == null) {
						base = string.substring(0, lastCharacter + 1);
					}
				} else {
					if (base == null) {
						base = string;
					}
				}
			}
			index--;
		}
		if (base == string) {
			score *= 2;
		} else if (base != null && base.length > 0) {
			score += Scorer.score(base, query).score;
		}
		var segmentCount = slashCount + 1;
		var depth = Math.max(1, 10 - segmentCount);
		score *= depth * 0.01;
		return score;
	}

	public static function score(string:String, query:String):Score {
		var initString = string;
		if (string == query || queryIsLastPathSegment(string, query)) {
			return {score: 1, parts: [RawString(string)]};
		}

		var totalCharacterScore:Float = 0;
		var queryLength = query.length;
		var stringLength = string.length;
		var indexInQuery = 0;
		var indexInString = 0;
		var parts = [];

		while (indexInQuery < queryLength) {
			var character = query.charAt(indexInQuery++);
			var lowerCaseIndex = string.indexOf(character.toLowerCase());
			var upperCaseIndex = string.indexOf(character.toUpperCase());
			var minIndex = Std.int(Math.min(lowerCaseIndex, upperCaseIndex));
			if (minIndex == -1) {
				minIndex = Std.int(Math.max(lowerCaseIndex, upperCaseIndex));
			}

			if (minIndex == -1) {
				return {score: 0, parts: [RawString(initString)]};
			}

			var part = parts.pop();
			if (part == null) {
				if (indexInString > 0 || minIndex > 0) {
					if (minIndex == 0) parts = [RawString(string.substring(0, indexInString))];
					else parts = [RawString(string.substring(0, indexInString + minIndex))];
				}

				parts.push(MatchedString(string.charAt(minIndex)));
			} else {
				switch part {
					case RawString(s):
						if (minIndex == 0) parts.push(part);
						else parts.push(RawString(s + string.substring(0, minIndex)));
						parts.push(MatchedString(string.charAt(minIndex)));

					case MatchedString(s):
						if (minIndex > 0) {
							parts.push(part);
							parts.push(RawString(string.substring(0, minIndex)));
							parts.push(MatchedString(string.charAt(minIndex)));
						} else {
							parts.push(MatchedString(s + string.charAt(minIndex)));
						}
				}
			}

			indexInString = minIndex;
			var characterScore = 0.1;
			if (string.charAt(indexInString) == character) {
				characterScore += 0.1;
			}
			if (indexInString == 0 || string.charAt(indexInString - 1) == Fuzzaldrin.PATH_SEPARATOR) {
				characterScore += 0.8;
            }
            else {
                var _ref = string.charAt(indexInString - 1);
                if (_ref == '-' || _ref == '_' || _ref == ' ') {
                    characterScore += 0.7;
                }
			}
			string = string.substring(indexInString + 1, stringLength);
			totalCharacterScore += characterScore;
		}

		if (string.length > 0) parts.push(RawString(string));
		var queryScore = totalCharacterScore / queryLength;
		return {
			score: ((queryScore * (queryLength / stringLength)) + queryScore) / 2,
			parts: parts
		}
	}

	static function queryIsLastPathSegment(string:String, query:String):Bool {
		if (string.charAt(string.length - query.length - 1) == Fuzzaldrin.PATH_SEPARATOR) {
			return string.lastIndexOf(query) == string.length - query.length;
        }
        return false;
    }

}
