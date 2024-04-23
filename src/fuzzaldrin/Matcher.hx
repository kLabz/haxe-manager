package fuzzaldrin;

class Matcher {

	public static function basenameMatch(string:String, query:String):Array<Int> {
		var index = string.length - 1;
		while (string.charAt(index) == Fuzzaldrin.PATH_SEPARATOR) {
			index--;
		}
		var slashCount = 0;
		var lastCharacter = index;
		var base:String = null;
		while (index >= 0) {
			if (string.charAt(index) == Fuzzaldrin.PATH_SEPARATOR) {
				slashCount++;
				if (base == null) {
					base = string.substring(index + 1, lastCharacter + 1);
				}
            }
            else if (index == 0) {
				if (lastCharacter < string.length - 1) {
					if (base == null) {
						base = string.substring(0, lastCharacter + 1);
					}
                }
                else {
					if (base == null) {
						base = string;
					}
				}
			}
			index--;
		}
		return Matcher.match(base, query, string.length - base.length);
	}

	public static function match(string:String, query:String, stringOffset:Int = 0):Array<Int> {
		if (string == query) {
			var results = [];
			for (i in stringOffset...stringOffset + string.length) {
				results.push(i);
			}
			return results;
		}
		var queryLength = query.length;
		var stringLength = string.length;
		var indexInQuery = 0;
		var indexInString = 0;
		var matches = [];
		while (indexInQuery < queryLength) {
			var character = query.charAt(indexInQuery++);
			var lowerCaseIndex = string.indexOf(character.toLowerCase());
			var upperCaseIndex = string.indexOf(character.toUpperCase());
			var minIndex = Std.int(Math.min(lowerCaseIndex, upperCaseIndex));
			if (minIndex == -1) {
				minIndex = Std.int(Math.max(lowerCaseIndex, upperCaseIndex));
			}
			indexInString = minIndex;
			if (indexInString == -1) {
				return [];
			}
			matches.push(stringOffset + indexInString);
			stringOffset += indexInString + 1;
			string = string.substring(indexInString + 1, stringLength);
		}
		return matches;
    }
    
}
