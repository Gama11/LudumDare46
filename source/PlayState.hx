class PlayState extends FlxState {
	var player:Player;
	var bullets:Bullets;
	var enemies:Enemies;

	override public function create() {
		bullets = new Bullets();
		enemies = new Enemies();

		for (i in 0...10) {
			enemies.spawn(FlxG.width / i, 10);
		}

		player = new Player(bullets);
		player.screenCenter();

		add(bullets);
		add(enemies);
		add(player);

		FlxG.mouse.visible = false;

		FlxG.debugger.visible = true;
		FlxG.debugger.drawDebug = true;
		FlxG.console.registerClass(Player);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		FlxG.overlap(bullets, enemies, onBulletHit);
	}

	function onBulletHit(bullet:Bullet, object:ITeam) {
		if (bullet.team != object.team) {
			var object:FlxSprite = cast object;
			object.hurt(bullet.damage);
		}
	}
}
