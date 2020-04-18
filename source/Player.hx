class Player extends FlxSprite implements ITeam {
	static inline final LerpFactor = 0.1;
	static inline final FireRate = 0.1;
	static inline final BulletOffset = 5;

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
		bullets.spawn(x + BulletOffset, y, Player);
		bullets.spawn(x + frameWidth - BulletOffset, y, Player);
	}
}
