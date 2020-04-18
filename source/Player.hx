class Player extends FlxSprite implements ITeam {
	static final Sound = 1;
	static final LerpFactor = 0.1;
	static final FireRate = 0.15;
	static final BulletOffsetX = 5;
	static final BulletOffsetY = 10;

	public var team(default, null):Team = Player;

	final bullets:Bullets;

	public function new(bullets) {
		super(AssetPaths.ship__png);
		this.bullets = bullets;
		new FlxTimer().start(FireRate, shoot, 0);
		health = 1;
	}

	override function update(elapsed:Float) {
		x = FlxMath.lerp(x, FlxG.mouse.x - frameWidth / 2, LerpFactor);
		y = FlxMath.lerp(y, FlxG.mouse.y - frameHeight / 2, LerpFactor);
		super.update(elapsed);
	}

	function shoot(_) {
		bullets.spawn(x + BulletOffsetX, y + BulletOffsetY, Player);
		bullets.spawn(x + frameWidth - BulletOffsetX, y + BulletOffsetY, Player);
		FlxG.sound.play('assets/sounds/pew$Sound.wav', 0.1);
	}
}
