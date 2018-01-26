package mew.parsing;

import mew.ast.Expr;
import mew.parsing.Emitter;

class AstEmitter implements Emitter<Expr> {
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

	public function if_(ifToken:TokenInfo, openParenToken:TokenInfo, condition:Expr, closeParenToken:TokenInfo, thenBody:Expr):Expr {
		return EIf(condition, thenBody, null);
	}

	public function ifElse(ifToken:TokenInfo, openParenToken:TokenInfo, condition:Expr, closeParenToken:TokenInfo, thenBody:Expr, elseToken:TokenInfo, elseBody:Expr):Expr {
		return EIf(condition, thenBody, elseBody);
	}

	public function block(openBraceToken:TokenInfo, exprs:Array<{expr:Expr, semicolon:TokenInfo}>, closeBraceToken:TokenInfo):Expr {
		return EBlock(exprs.map(e -> e.expr));
	}
}