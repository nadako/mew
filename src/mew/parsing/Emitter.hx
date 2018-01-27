package mew.parsing;

interface Emitter<TExpr,TPattern> {
	function string(token:TokenInfo):TExpr;
	function integer(token:TokenInfo):TExpr;
	function ident(token:TokenInfo):TExpr;
	function add(a:TExpr, plusToken:TokenInfo, b:TExpr):TExpr;
	function sub(a:TExpr, minusToken:TokenInfo, b:TExpr):TExpr;
	function mul(a:TExpr, asteriskToken:TokenInfo, b:TExpr):TExpr;
	function div(a:TExpr, slashToken:TokenInfo, b:TExpr):TExpr;
	function assign(a:TExpr, equalsToken:TokenInfo, b:TExpr):TExpr;
	function call(callee:TExpr, openParenToken:TokenInfo, args:CommaSeparated<TExpr>, closeParenToken:TokenInfo):TExpr;
	function paren(openParenToken:TokenInfo, expr:TExpr, closeParenToken:TokenInfo):TExpr;
	function field(expr:TExpr, dotToken:TokenInfo, fieldToken:TokenInfo):TExpr;
	function if_(ifToken:TokenInfo, openParenToken:TokenInfo, condition:TExpr, closeParenToken:TokenInfo, thenBody:TExpr):TExpr;
	function ifElse(ifToken:TokenInfo, openParenToken:TokenInfo, condition:TExpr, closeParenToken:TokenInfo, thenBody:TExpr, elseToken:TokenInfo, elseBody:TExpr):TExpr;
	function while_(whileToken:TokenInfo, openParenToken:TokenInfo, condition:TExpr, closeParenToken:TokenInfo, body:TExpr):TExpr;
	function break_(token:TokenInfo):TExpr;
	function continue_(token:TokenInfo):TExpr;
	function block(openBraceToken:TokenInfo, exprs:Array<{expr:TExpr, semicolon:TokenInfo}>, closeBraceToken:TokenInfo):TExpr;
	function var_(varToken:TokenInfo, pattern:TPattern, equalsToken:TokenInfo, value:TExpr):TExpr;

	function patternName(nameToken:TokenInfo):TPattern;
}

typedef CommaSeparated<T> = Null<{head:T, tail:Array<{comma:TokenInfo, value:T}>}>;
