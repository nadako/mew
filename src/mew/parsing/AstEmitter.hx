package mew.parsing;

import mew.ast.Expr;
import mew.parsing.Emitter;

class AstEmitter implements Emitter<Expr,Pattern> {
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

	public function sub(a:Expr, minusToken:TokenInfo, b:Expr):Expr {
		return EBinop(OpSub, a, b);
	}

	public function mul(a:Expr, asteriskToken:TokenInfo, b:Expr):Expr {
		return EBinop(OpMul, a, b);
	}

	public function div(a:Expr, slashToken:TokenInfo, b:Expr):Expr {
		return EBinop(OpDiv, a, b);
	}

	public function assign(a:Expr, equalsToken:TokenInfo, b:Expr):Expr {
		return EBinop(OpAssign, a, b);
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

	public function if_(ifToken:TokenInfo, openParenToken:TokenInfo, condition:Expr, closeParenToken:TokenInfo, thenBody:Expr):Expr {
		return EIf(condition, thenBody, null);
	}

	public function while_(whileToken:TokenInfo, openParenToken:TokenInfo, condition:Expr, closeParenToken:TokenInfo, body:Expr):Expr {
		return EWhile(condition, body);
	}

	public function break_(token:TokenInfo):Expr {
		return EBreak;
	}

	public function continue_(token:TokenInfo):Expr {
		return EContinue;
	}

	public function ifElse(ifToken:TokenInfo, openParenToken:TokenInfo, condition:Expr, closeParenToken:TokenInfo, thenBody:Expr, elseToken:TokenInfo, elseBody:Expr):Expr {
		return EIf(condition, thenBody, elseBody);
	}

	public function block(openBraceToken:TokenInfo, exprs:Array<{expr:Expr, semicolon:TokenInfo}>, closeBraceToken:TokenInfo):Expr {
		return EBlock(exprs.map(e -> e.expr));
	}

	public function var_(varToken:TokenInfo, pattern:Pattern, equalsToken:TokenInfo, value:Expr):Expr {
		return EVar(pattern, value);
	}

	public function fun(funToken:TokenInfo, nameToken:Null<TokenInfo>, openParenToken:TokenInfo, args:CommaSeparated<Emitter.FunctionArg<Pattern>>, closeParenToken:TokenInfo, expr:Expr):Expr {
		var args = if (args == null) [] else [args.head].concat(args.tail.map(e -> e.value));
		return EFun(if (nameToken != null) nameToken.token.text else null, {
			args: args,
			body: expr,
		});
	}

	public function patternName(nameToken:TokenInfo):Pattern {
		return PName(nameToken.token.text);
	}
}
