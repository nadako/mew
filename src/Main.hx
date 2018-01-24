class Main {
	static function main() {
		var scanner = new Scanner(sys.io.File.getContent("Main.mew"));
		var head = scanner.scan();
		while (head != null) {
			trace(Std.string(head.kind), haxe.Json.stringify(head.text));
			head = head.next;
		}
	}
}
