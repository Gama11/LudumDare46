class Bullets extends FlxTypedGroup<Bullet> {
	public function new() {
		super();
	}

	public function spawn(x, y, team, color, angle, type, speed) {
		return recycle(Bullet, Bullet.new).init(x, y, team, color, angle, type, speed);
	}
}
