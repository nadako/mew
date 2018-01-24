class Main {
	static function main() {
		var scanner = new Scanner(sys.io.File.getContent("Main.mew"));
		var head = scanner.scan();
		var parser = new Parser(head);
		parser.parse();
	}
}
