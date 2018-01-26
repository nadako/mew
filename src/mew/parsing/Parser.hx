package mew.parsing;

import mew.lexing.Token;

class TokenInfo {
	public var token:Token;
	public var leadTrivia:Array<Token>;
	public var trailTrivia:Array<Token>;
	public function new() {}
}

interface ParserHandler<TExpr> {
	function string(token:TokenInfo):TExpr;
	function integer(token:TokenInfo):TExpr;
	function ident(token:TokenInfo):TExpr;
	function add(a:TExpr, plusToken:TokenInfo, b:TExpr):TExpr;
	function sub(a:TExpr, plusToken:TokenInfo, b:TExpr):TExpr;
	function mul(a:TExpr, plusToken:TokenInfo, b:TExpr):TExpr;
	function div(a:TExpr, plusToken:TokenInfo, b:TExpr):TExpr;
	function call(callee:TExpr, openParenToken:TokenInfo, args:CommaSeparated<TExpr>, closeParenToken:TokenInfo):TExpr;
	function paren(openParenToken:TokenInfo, expr:TExpr, closeParenToken:TokenInfo):TExpr;
	function field(expr:TExpr, dotToken:TokenInfo, fieldToken:TokenInfo):TExpr;
	function if_(ifToken:TokenInfo, openParenToken:TokenInfo, condition:TExpr, closeParenToken:TokenInfo, thenBody:TExpr):TExpr;
	function ifElse(ifToken:TokenInfo, openParenToken:TokenInfo, condition:TExpr, closeParenToken:TokenInfo, thenBody:TExpr, elseToken:TokenInfo, elseBody:TExpr):TExpr;
	function block(openBraceToken:TokenInfo, exprs:Array<{expr:TExpr, semicolon:TokenInfo}>, closeBraceToken:TokenInfo):TExpr;
}

typedef CommaSeparated<T> = Null<{head:T, tail:Array<{comma:TokenInfo, value:T}>}>;

class Parser<TExpr> {
	var head:Token;
	var trivia:Array<Token>;
	var handler:ParserHandler<TExpr>;

	public function new(head, handler) {
		this.head = head;
		this.handler = handler;
		this.trivia = [];
	}

	public function parse() return parseExpr();

	function parseExpr():TExpr {
		var token = advance();
		switch token {
			case {kind: TkString}:
				return parseExprNext(handler.string(consume()));
			case {kind: TkInteger}:
				return parseExprNext(handler.integer(consume()));
			case {kind: TkIdent, text: "if"}:
				var ifToken = consume();
				var parenOpenToken = expect(t -> t.kind == TkParenOpen);
				var condition = parseExpr();
				var parenCloseToken = expect(t -> t.kind == TkParenClose);
				var then = parseExpr();
				switch advance() {
					case {kind: TkIdent, text: "else"}:
						var elseToken = consume();
						var elseBody = parseExpr();
						return handler.ifElse(ifToken, parenOpenToken, condition, parenCloseToken, then, elseToken, elseBody);
					case _:
						return handler.if_(ifToken, parenOpenToken, condition, parenCloseToken, then);
				}

			case {kind: TkIdent}:
				return parseExprNext(handler.ident(consume()));
			case {kind: TkParenOpen}:
				var parenOpenToken = consume();
				var expr = parseExpr();
				var parenCloseToken = expect(t -> t.kind == TkParenClose);
				return parseExprNext(handler.paren(parenOpenToken, expr, parenCloseToken));
			case {kind: TkBraceOpen}:
				var braceOpenToken = consume();
				var contents = [];
				while (true) {
					var expr = parse();
					if (expr == null)
						break;
					var semicolon = expect(t -> t.kind == TkSemicolon);
					contents.push({expr: expr, semicolon: semicolon});
				}
				var braceCloseToken = expect(t -> t.kind == TkBraceClose);
				return handler.block(braceOpenToken, contents, braceCloseToken);
			case _:
				return null;
		}
	}

	function parseExprNext(leftHand:TExpr):TExpr {
		var token = advance();
		switch token {
			case {kind: TkPlus}:
				var plusToken = consume();
				var rightHand = parseExpr();
				return handler.add(leftHand, plusToken, rightHand);
			case {kind: TkMinus}:
				var minusToken = consume();
				var rightHand = parseExpr();
				return handler.sub(leftHand, minusToken, rightHand);
			case {kind: TkAsterisk}:
				var asteriskToken = consume();
				var rightHand = parseExpr();
				return handler.mul(leftHand, asteriskToken, rightHand);
			case {kind: TkSlash}:
				var slashToken = consume();
				var rightHand = parseExpr();
				return handler.div(leftHand, slashToken, rightHand);
			case {kind: TkParenOpen}:
				var openParenToken = consume();
				var args = parseCommaSeparated(parseExpr);
				var closeParenToken = expect(t -> t.kind == TkParenClose);
				return parseExprNext(handler.call(leftHand, openParenToken, args, closeParenToken));
			case {kind: TkDot}:
				var dotToken = consume();
				var fieldNameToken = expect(t -> t.kind == TkIdent);
				return parseExprNext(handler.field(leftHand, dotToken, fieldNameToken));
			case _:
				return leftHand;
		}
	}

	function parseCommaSeparated(parse:()->TExpr):CommaSeparated<TExpr> {
		var head = parse();
		if (head == null)
			return null;
		var tail = [];
		while (true) {
			var token = advance();
			switch token {
				case {kind: TkComma}:
					var comma = consume();
					var expr = parse();
					if (expr == null)
						break;
					tail.push({comma: comma, value: expr});
				case _:
					break;
			}
		}
		return {head: head, tail: tail};
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
