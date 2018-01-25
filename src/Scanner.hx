using StringTools;

class Scanner {
	final text:String;
	final end:Int;
	var pos:Int;
	var tokenStartPos:Int;

	var head:Token;
	var tail:Token;

	public function new(text) {
		this.text = text;
		pos = tokenStartPos = 0;
		end = text.length;
	}

	public function scan():Token {
		while (true) {
			tokenStartPos = pos;
			if (pos >= end) {
				add(TkEof);
				return head;
			}

			var ch = text.fastCodeAt(pos);
			switch ch {
				case " ".code | "\t".code:
					pos++;
					while (pos < end) {
						ch = text.fastCodeAt(pos);
						switch ch {
							case " ".code | "\t".code:
								pos++;
							case _:
								break;
						}
					}
					add(TkWhitespace);

				case "\r".code:
					pos++;
					if (text.fastCodeAt(pos) == "\n".code)
						pos++;
					add(TkNewline);

				case "\n".code:
					pos++;
					add(TkNewline);

				case "(".code:
					pos++;
					add(TkParenOpen);

				case ")".code:
					pos++;
					add(TkParenClose);

				case "{".code:
					pos++;
					add(TkBraceOpen);

				case "}".code:
					pos++;
					add(TkBraceClose);

				case ".".code:
					pos++;
					add(TkDot);

				case ",".code:
					pos++;
					add(TkComma);

				case ":".code:
					pos++;
					add(TkColon);

				case ";".code:
					pos++;
					add(TkSemicolon);

				case "*".code:
					pos++;
					add(TkAsterisk);

				case "/".code:
					pos++;
					if (pos < end) {
						switch text.fastCodeAt(pos) {
							case "/".code:
								pos++;
								while (pos < end) {
									var ch = text.fastCodeAt(pos);
									if (ch == "\r".code || ch == "\n".code)
										break;
									pos++;
								}
								add(TkLineComment);

							case "*".code:
								pos++;
								var doc = false;
								if (pos < end && text.fastCodeAt(pos) == "*".code) {
									doc = true;
									pos++;
								}
								while (pos < end) {
									if (text.fastCodeAt(pos) == "*".code && pos + 1 < end && text.fastCodeAt(pos + 1) == "/".code) {
										pos += 2;
										break;
									}
									pos++;
								}
								add(if (doc) TkDocComment else TkBlockComment);

							case _:
								add(TkSlash);
						}
					} else {
						add(TkSlash);
					}

				case _ if (isIdentStart(ch)):
					pos++;
					while (pos < end) {
						ch = text.fastCodeAt(pos);
						if (!isIdentPart(ch))
							break;
						pos++;
					}
					add(TkIdent);

				case _:
					pos++;
					add(TkInvalid);
			}
		}
	}

	inline function isNumber(ch) {
		return ch >= "0".code && ch <= "9".code;
	}

	inline function isIdentStart(ch) {
		return ch == "_".code || (ch >= "a".code && ch <= "z".code) || (ch >= "A".code && ch <= "Z".code);
	}

	inline function isIdentPart(ch) {
		return isNumber(ch) || isIdentStart(ch);
	}

	function add(kind) {
		var token = new Token(kind, text.substring(tokenStartPos, pos));
		if (head == null) {
			head = tail = token;
		} else {
			token.prev = tail;
			tail.next = token;
			tail = token;
		}
	}
}
