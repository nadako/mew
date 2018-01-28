package mew.parsing;

import mew.lexing.Token;
import mew.parsing.Emitter;

class Parser<TExpr,TPattern> {
	var head:Token;
	var trivia:Array<Token>;
	var emitter:Emitter<TExpr,TPattern>;

	public function new(head, emitter) {
		this.head = head;
		this.emitter = emitter;
		this.trivia = [];
	}

	public function parse() return parseExpr();

	function parseExpr():TExpr {
		var token = advance();
		switch token {
			case {kind: TkString}:
				return parseExprNext(emitter.string(consume()));
			case {kind: TkInteger}:
				return parseExprNext(emitter.integer(consume()));
			case {kind: TkIdent, text: "fun"}:
				var funToken = consume();
				var nameToken =
					switch advance() {
						case {kind: TkIdent}: consume();
						case _: null;
					}
				var parenOpenToken = expect(t -> t.kind == TkParenOpen);
				var args = parseCommaSeparated(parseFunctionArg);
				var parenCloseToken = expect(t -> t.kind == TkParenClose);
				var expr = parseExpr();
				return emitter.fun(funToken, nameToken, parenOpenToken, args, parenCloseToken, expr);
			case {kind: TkIdent, text: "var"}:
				var varToken = consume();
				var pattern = parsePattern();
				var equalsToken = expect(t -> t.kind == TkEquals);
				var expr = parseExpr();
				return emitter.var_(varToken, pattern, equalsToken, expr);
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
						return emitter.ifElse(ifToken, parenOpenToken, condition, parenCloseToken, then, elseToken, elseBody);
					case _:
						return emitter.if_(ifToken, parenOpenToken, condition, parenCloseToken, then);
				}
			case {kind: TkIdent, text: "while"}:
				var whileToken = consume();
				var parenOpenToken = expect(t -> t.kind == TkParenOpen);
				var condition = parseExpr();
				var parenCloseToken = expect(t -> t.kind == TkParenClose);
				var body = parseExpr();
				return emitter.while_(whileToken, parenOpenToken, condition, parenCloseToken, body);
			case {kind: TkIdent, text: "break"}:
				return emitter.break_(consume());
			case {kind: TkIdent, text: "continue"}:
				return emitter.continue_(consume());
			case {kind: TkIdent}:
				return parseExprNext(emitter.ident(consume()));
			case {kind: TkParenOpen}:
				var parenOpenToken = consume();
				var expr = parseExpr();
				var parenCloseToken = expect(t -> t.kind == TkParenClose);
				return parseExprNext(emitter.paren(parenOpenToken, expr, parenCloseToken));
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
				return emitter.block(braceOpenToken, contents, braceCloseToken);
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
				return emitter.add(leftHand, plusToken, rightHand);
			case {kind: TkMinus}:
				var minusToken = consume();
				var rightHand = parseExpr();
				return emitter.sub(leftHand, minusToken, rightHand);
			case {kind: TkAsterisk}:
				var asteriskToken = consume();
				var rightHand = parseExpr();
				return emitter.mul(leftHand, asteriskToken, rightHand);
			case {kind: TkSlash}:
				var slashToken = consume();
				var rightHand = parseExpr();
				return emitter.div(leftHand, slashToken, rightHand);
			case {kind: TkParenOpen}:
				var openParenToken = consume();
				var args = parseCommaSeparated(parseExpr);
				var closeParenToken = expect(t -> t.kind == TkParenClose);
				return parseExprNext(emitter.call(leftHand, openParenToken, args, closeParenToken));
			case {kind: TkDot}:
				var dotToken = consume();
				var fieldNameToken = expect(t -> t.kind == TkIdent);
				return parseExprNext(emitter.field(leftHand, dotToken, fieldNameToken));
			case {kind: TkEquals}:
				var equalsToken = consume();
				var rightHand = parseExpr();
				return emitter.assign(leftHand, equalsToken, rightHand);
			case _:
				return leftHand;
		}
	}

	function parsePattern():TPattern {
		switch advance() {
			case {kind: TkIdent}:
				return emitter.patternName(consume());
			case _:
				return null;
		}
	}

	function parseFunctionArg():FunctionArg<TPattern> {
		var pattern = parsePattern();
		return {pattern: pattern};
	}

	function parseCommaSeparated<TRet>(parse:()->TRet):CommaSeparated<TRet> {
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
