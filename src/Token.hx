class Token {
	public var kind:TokenKind;
	public var text:String;
	public var prev:Token;
	public var next:Token;

	public function new(kind, text) {
		this.kind = kind;
		this.text = text;
	}
}

enum TokenKind {
	TkWhitespace;
	TkNewline;
	TkIdent;
	TkBraceOpen;
	TkBraceClose;
	TkParenOpen;
	TkParenClose;
	TkColon;
	TkSemicolon;
	TkDot;
	TkComma;
	TkInvalid;
	TkEof;
}
