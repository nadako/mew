class Main {
	static function main() {
		haxe.Log.trace = haxe.Log.trace;
		var scanner = new Scanner(sys.io.File.getContent("Main.mew"));
		var head = scanner.scan();
		var parser = new Parser(head);
		var result = parser.parse();
		trace(result);
	}
}
