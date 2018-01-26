package mew;

import mew.parsing.Parser;
import mew.parsing.AstEmitter;
import mew.lexing.Scanner;

class Main {
	static function main() {
		haxe.Log.trace = haxe.Log.trace;
		var scanner = new Scanner(sys.io.File.getContent("Main.mew"));
		var parser = new Parser(scanner.scan(), new AstEmitter());
		var result = parser.parse();
		trace(result);
	}
}
