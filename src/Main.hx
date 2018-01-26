import Parser;

enum Literal {
	LString(string:String);
	LInt(string:String);
}

enum Binop {
	OpAdd;
	OpSub;
	OpMul;
	OpDiv;
}

enum Expr {
	ELiteral(literal:Literal);
	EIdent(ident:String);
	EBinop(op:Binop, a:Expr, b:Expr);
	ECall(expr:Expr, args:Array<Expr>);
	EParen(expr:Expr);
	EField(expr:Expr, field:String);
}

class Main implements ParserHandler<Expr> {
	public function new() {}

	public function string(token:TokenInfo):Expr {
		return ELiteral(LString(token.token.text.substring(1, token.token.text.length - 1)));
	}

	public function integer(token:TokenInfo):Expr {
		return ELiteral(LInt(token.token.text));
	}

	public function ident(token:TokenInfo):Expr {
		return EIdent(token.token.text);
	}

	public function add(a:Expr, plusToken:TokenInfo, b:Expr):Expr {
		return EBinop(OpAdd, a, b);
	}

	public function sub(a:Expr, plusToken:TokenInfo, b:Expr):Expr {
		return EBinop(OpSub, a, b);
	}

	public function mul(a:Expr, plusToken:TokenInfo, b:Expr):Expr {
		return EBinop(OpMul, a, b);
	}

	public function div(a:Expr, plusToken:TokenInfo, b:Expr):Expr {
		return EBinop(OpDiv, a, b);
	}

	public function paren(openParenToken:TokenInfo, expr:Expr, closeParenToken:TokenInfo):Expr {
		return EParen(expr);
	}

	public function call(callee:Expr, openParenToken:TokenInfo, args:CommaSeparated<Expr>, closeParenToken:TokenInfo):Expr {
		var callArgs = if (args == null) [] else [args.head].concat(args.tail.map(e -> e.value));
		return ECall(callee, callArgs);
	}

	public function field(expr:Expr, dotToken:TokenInfo, fieldToken:TokenInfo):Expr {
		return EField(expr, fieldToken.token.text);
	}

	static function main() {
		haxe.Log.trace = haxe.Log.trace;
		var scanner = new Scanner(sys.io.File.getContent("Main.mew"));
		var head = scanner.scan();
		// do {
		// 	trace(head);
		// 	head = head.next;
		// } while (head.kind != TkEof);
		var parser = new Parser(head, new Main());
		var result = parser.parse();
		trace(result);
	}
}
