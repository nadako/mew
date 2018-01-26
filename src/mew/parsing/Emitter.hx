package mew.parsing;

interface Emitter<TExpr> {
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
