/*
 * Copyright (C)2005-2018 Haxe Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

package haxe.iterators;

/**
	This iterator can be used to iterate over char indexes and char codes in a string.

	Note that char codes may differ across platforms because of different
	internal encoding of strings in different runtimes.
**/
class StringKeyValueIterator {
	var offset = 0;
	var s:String;

	/**
		Create a new `StringKeyValueIterator` over String `s`.
	**/
	public inline function new(s:String) {
		this.s = s;
	}

	/**
		See `KeyValueIterator.hasNext`
	**/
	public inline function hasNext() {
		return offset < s.length;
	}

	/**
		See `KeyValueIterator.next`
	**/
	public inline function next() {
		return {key: offset, value: StringTools.fastCodeAt(s, offset++)};
	}
}
