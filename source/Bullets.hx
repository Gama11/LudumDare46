class Bullets extends FlxTypedGroup<Bullet> {
	public function new() {
		super();
	}

	public function spawn(x, y, team) {
		return recycle(Bullet, Bullet.new).init(x, y, team);
	}
}
