class Parser {
	var head:Token;
	var lead:Token;
	var trail:Token;

	public function new(head) {
		this.head = head;
	}

	public function parse() {
		var token = head;
		while (token != null) {
			trace(token.kind, haxe.Json.stringify(token.text));
			token = token.next;
		}
	}
}

class TokenInfo {
	public var token:Token;
	public var leadTrivia:Array<Token>;
	public var trailTrivia:Array<Token>;
	public function new() {}
}
