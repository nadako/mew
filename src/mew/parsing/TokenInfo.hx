package mew.parsing;

import mew.lexing.Token;

class TokenInfo {
	public var token:Token;
	public var leadTrivia:Array<Token>;
	public var trailTrivia:Array<Token>;
	public function new() {}
}
