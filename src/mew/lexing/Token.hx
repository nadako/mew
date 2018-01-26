package mew.lexing;

class Token {
	public var kind:TokenKind;
	public var text:String;
	public var prev:Token;
	public var next:Token;

	public function new(kind, text) {
		this.kind = kind;
		this.text = text;
	}

	@:keep
	public function toString() {
		return '$kind(${haxe.Json.stringify(text)})';
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
	TkSlash;
	TkAsterisk;
	TkPlus;
	TkMinus;
	TkInteger;
	TkString;
	TkInvalid;
	TkLineComment;
	TkBlockComment;
	TkDocComment;
	TkEof;
}
