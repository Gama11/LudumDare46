import flixel.effects.particles.FlxEmitter.FlxEmitterMode;

class SmokeParticle extends FlxParticle {
	public function new() {
		super();
	}

	override function onEmit() {
		super.onEmit();
		lifespan = 1;
	}

	override function update(elapsed) {
		super.update(elapsed);
		scale.set(scale.x, scale.x);
		velocity.x = 0;
	}
}

class Player extends FlxSprite implements ITeam {
	static final Sound = 1;
	static final LerpFactor = 0.05;
	static final FireRate = 0.15;
	static final BulletOffsetX = 5;
	static final BulletOffsetY = 10;
	static final RollDuration = 0.5;
	static final Kickback = 3;

	public var team(default, null):Team = Player;
	public var exhaust1(default, null):FlxTypedEmitter<SmokeParticle>;
	public var exhaust2(default, null):FlxTypedEmitter<SmokeParticle>;

	final bullets:Bullets;
	var rolling = false;
	var currentSpeed = 0.007;

	public function new(bullets) {
		super(AssetPaths.ship__png);
		this.bullets = bullets;
		health = 1;

		function makeExhaust() {
			var exhaust = new FlxTypedEmitter<SmokeParticle>();
			exhaust.particleClass = SmokeParticle;
			exhaust.launchMode = FlxEmitterMode.SQUARE;
			exhaust.velocity.start.set(new FlxPoint(0, 50), new FlxPoint(0, 60));
			exhaust.velocity.end.set(new FlxPoint(0, 10), new FlxPoint(0, 20));
			exhaust.alpha.start.set(0.2, 0.3);
			exhaust.alpha.end.set(0);
			exhaust.scale.start.set(new FlxPoint(0.4, 0.4), new FlxPoint(1.5, 1.5));
			exhaust.scale.end.set(new FlxPoint(0.1, 0.1), new FlxPoint(0.2, 0.2));
			exhaust.color.start.min = exhaust.color.start.max = FlxG.random.color(FlxColor.WHITE, FlxColor.BLACK, 1, true);
			exhaust.loadParticles("assets/images/smoke.png");
			exhaust.start(false, 0.1);
			return exhaust;
		}
		exhaust1 = makeExhaust();
		exhaust2 = makeExhaust();
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

		var offset = 6;

		exhaust1.x = x + offset;
		exhaust1.y = y + frameHeight - 2;

		exhaust2.x = x + frameWidth - offset;
		exhaust2.y = y + frameHeight - 2;

		super.update(elapsed);
	}

	function shoot(_) {
		var fire = bullets.spawn.bind(_, _, Player, FlxColor.YELLOW);
		fire(x + BulletOffsetX, y + BulletOffsetY);
		fire(x + frameWidth - BulletOffsetX, y + BulletOffsetY);
		FlxG.sound.play('assets/sounds/pew$Sound.wav', 0.1);
		y += Kickback;
	}

	public function startFiring() {
		new FlxTimer().start(FireRate, shoot, 0);
		currentSpeed = LerpFactor;
	}
}
