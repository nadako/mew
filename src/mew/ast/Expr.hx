package mew.ast;

enum Literal {
	LString(string:String);
	LInt(string:String);
}

enum Binop {
	OpAdd;
	OpSub;
	OpMul;
	OpDiv;
	OpAssign;
}

enum Expr {
	ELiteral(literal:Literal);
	EIdent(ident:String);
	EBinop(op:Binop, a:Expr, b:Expr);
	ECall(expr:Expr, args:Array<Expr>);
	EParen(expr:Expr);
	EField(expr:Expr, field:String);
	EIf(cond:Expr, then:Expr, eelse:Null<Expr>);
	EWhile(cond:Expr, body:Expr);
	EBreak;
	EContinue;
	EBlock(exprs:Array<Expr>);
	EVar(pattern:Pattern, value:Expr);
}

enum Pattern {
	PName(name:String);
}
