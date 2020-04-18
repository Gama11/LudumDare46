class Player extends FlxSprite implements ITeam {
	static final Sound = 1;
	static final LerpFactor = 0.05;
	static final FireRate = 0.15;
	static final BulletOffsetX = 5;
	static final BulletOffsetY = 10;
	static final RollDuration = 0.5;

	public var team(default, null):Team = Player;

	final bullets:Bullets;
	var rolling = false;
	var currentSpeed = 0.004;

	public function new(bullets) {
		super(AssetPaths.ship__png);
		this.bullets = bullets;
		health = 1;
	}

	override function update(elapsed:Float) {
		if (FlxG.mouse.justPressedRight && !rolling) {
			rolling = true;
			alpha = 0.5;
			solid = false;
			FlxG.sound.play("assets/sounds/jump.wav");
			FlxTween.tween(this, {
				"scale.x": -1,
				"scale.y": 1.2
			}, RollDuration, {
				type: PINGPONG,
				onComplete: function(tween) {
					tween.cancel();
					scale.set(1, 1);
					rolling = false;
					alpha = 1;
					solid = true;
				}
			});
		}

		var factor = currentSpeed;
		if (rolling) {
			factor *= 4;
		}
		x = FlxMath.lerp(x, FlxG.mouse.x - frameWidth / 2, factor);
		y = FlxMath.lerp(y, FlxG.mouse.y - frameHeight / 2, factor);

		super.update(elapsed);
	}

	function shoot(_) {
		var fire = bullets.spawn.bind(_, _, Player, FlxColor.YELLOW);
		fire(x + BulletOffsetX, y + BulletOffsetY);
		fire(x + frameWidth - BulletOffsetX, y + BulletOffsetY);
		FlxG.sound.play('assets/sounds/pew$Sound.wav', 0.1);
	}

	public function startFiring() {
		new FlxTimer().start(FireRate, shoot, 0);
		currentSpeed = LerpFactor;
	}
}
