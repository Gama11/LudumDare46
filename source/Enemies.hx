class Enemies extends FlxTypedGroup<Enemy> {
	public function new() {
		super();
	}

	public function spawn(x, y) {
		return recycle(Enemy, Enemy.new).init(x, y);
	}
}
