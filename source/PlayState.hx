class PlayState extends FlxState {
	var player:Player;
	var bullets:Bullets;
	var enemies:Enemies;
	var cursor:FlxSprite;

	override public function create() {
		bullets = new Bullets();
		enemies = new Enemies();

		for (i in 0...10) {
			enemies.spawn(FlxG.width / i, 10);
		}

		player = new Player(bullets);
		player.screenCenter();

		cursor = new FlxSprite();
		cursor.makeGraphic(4, 4, FlxColor.RED);
		cursor.alpha = 0.5;

		add(bullets);
		add(enemies);
		add(player);
		add(cursor);

		FlxG.mouse.visible = false;

		FlxG.debugger.visible = true;
		FlxG.debugger.drawDebug = true;
		FlxG.console.registerClass(Player);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		FlxG.overlap(bullets, enemies, onBulletHit);

		cursor.x = FlxG.mouse.x;
		cursor.y = FlxG.mouse.y;

		cursor.visible = FlxMath.distanceBetween(cursor, player) > 10;
	}

	function onBulletHit(bullet:Bullet, object:ITeam) {
		if (bullet.team != object.team) {
			var object:FlxSprite = cast object;
			object.hurt(bullet.damage);
		}
	}
}
