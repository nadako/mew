class Parser {
	var head:Token;
	var trivia:Array<Token>;

	public function new(head) {
		this.head = head;
		this.trivia = [];
	}

	public function parse() {
		switch advance() {
			case {kind: TkIdent, text: "fun"}:
				return parseFunction();
			case _:
				return null;
		}
	}

	function parseFunction():SyntaxFunction {
		var funToken = consume();

		var nameToken = expect(t -> t.kind == TkIdent);

		var openParenToken = expect(t -> t.kind == TkParenOpen);
		var closeParenToken = expect(t -> t.kind == TkParenClose);

		var node = new SyntaxFunction();
		node.funToken = funToken;
		node.nameToken = nameToken;
		node.openParenToken = openParenToken;
		node.closeParenToken = closeParenToken;
		return node;
	}

	function expect(check):TokenInfo {
		var token = advance();
		return if (check(token)) consume() else null;
	}

	function advance():Token {
		while (true) {
			switch head.kind {
				case TkWhitespace | TkNewline | TkLineComment | TkBlockComment | TkDocComment | TkInvalid:
					trivia.push(head);
				case _:
					break;
			}
			head = head.next;
		}
		return head;
	}

	function consume():TokenInfo {
		var info = new TokenInfo();
		info.token = head;
		info.leadTrivia = trivia;

		trivia = [];
		head = head.next;

		info.trailTrivia = consumeTrailTrivia();
		return info;
	}

	function consumeTrailTrivia():Array<Token> {
		var result = [];
		while (true) {
			switch head.kind {
				case TkWhitespace | TkLineComment | TkBlockComment | TkDocComment | TkInvalid:
					result.push(head);
					head = head.next;
				case TkNewline:
					result.push(head);
					head = head.next;
					break;
				case _:
					break;
			}
		}
		return result;
	}
}

class TokenInfo {
	public var token:Token;
	public var leadTrivia:Array<Token>;
	public var trailTrivia:Array<Token>;
	public function new() {}
}

class SyntaxFunction {
	public var funToken:TokenInfo;
	public var nameToken:TokenInfo;
	public var openParenToken:TokenInfo;
	public var closeParenToken:TokenInfo;
	public function new() {}
}
