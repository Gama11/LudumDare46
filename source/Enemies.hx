class Enemies extends FlxTypedGroup<Enemy> {
	final bullets:Bullets;
	var dir = -1;

	public function new(bullets:Bullets) {
		super();
		this.bullets = bullets;
	}

	public function spawn(x, y, type) {
		return recycle(Enemy, Enemy.new.bind(bullets)).init(x, y, type);
	}

	public function startSpawning() {
		new FlxTimer().start(3, function(timer) {
			var xOffset = if (dir == -1) 300 else -100;
			for (i in 0...5) {
				spawn(10 + i * 100 + xOffset, -100 - i * 10, Basic(dir));
			}
			dir *= -1;
		}, 0);
	}
}
