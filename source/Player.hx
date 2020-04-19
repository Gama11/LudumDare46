import flixel.effects.particles.FlxEmitter;

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
	static final LerpFactor = 0.02;
	static final FireRate = 0.2;
	static final BulletOffsetX = 5;
	static final BulletOffsetY = 10;
	static final RollDuration = 0.5;
	static final RollCooldown = 1;
	static final Kickback = 6;

	public var team(default, null):Team = Player;
	public var exhaust1(default, null):FlxTypedEmitter<SmokeParticle>;
	public var exhaust2(default, null):FlxTypedEmitter<SmokeParticle>;
	public var charge(default, null):Float = 1;

	final bullets:Bullets;
	var firing = false;
	var rolling = false;
	final fireTimer = new FlxTimer();

	public function new(bullets) {
		super(AssetPaths.ship__png);
		this.bullets = bullets;
		health = 1;

		function makeExhaust() {
			var exhaust = new FlxTypedEmitter<SmokeParticle>();
			exhaust.particleClass = SmokeParticle;
			exhaust.launchMode = FlxEmitterMode.SQUARE;
			exhaust.velocity.start.set(new FlxPoint(0, 150), new FlxPoint(0, 160));
			exhaust.velocity.end.set(new FlxPoint(0, 110), new FlxPoint(0, 120));
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

	function isCharged() {
		return charge >= 1;
	}

	override function update(elapsed:Float) {
		if (FlxG.mouse.justPressedRight) {
			if (!rolling && isCharged()) {
				rolling = true;
				solid = false;
				charge = 0;
				setColorTransform(1, 0, 0, 255, 0, 0);
				FlxG.sound.play("assets/sounds/jump.wav");
				FlxTween.tween(this, {
					"scale.x": -1,
					"scale.y": 1.2,
					x: FlxG.mouse.x - frameWidth / 2,
					y: FlxG.mouse.y - frameHeight / 2
				}, RollDuration, {
					type: PINGPONG,
					onComplete: function(tween) {
						tween.cancel();
						scale.set(1, 1);
						rolling = false;
						solid = true;
						setColorTransform();
					}
				});
			} else {
				FlxG.sound.play("assets/sounds/blocked.wav");
			}
		}

		if (!FlxG.keys.pressed.SPACE && !FlxG.mouse.pressed && !rolling) {
			var factor = LerpFactor;
			x = FlxMath.lerp(x, FlxG.mouse.x - frameWidth / 2, factor);
			y = FlxMath.lerp(y, FlxG.mouse.y - frameHeight / 2, factor);
		}

		if (!isCharged() && !rolling) {
			charge += elapsed / RollCooldown;
		}

		var offset = 10;

		exhaust1.x = x + offset;
		exhaust1.y = y + frameHeight - 2;

		exhaust2.x = x + frameWidth - offset;
		exhaust2.y = y + frameHeight - 2;

		super.update(elapsed);
	}

	function shoot(_) {
		if (FlxG.random.bool(5)) {
			return;
		}
		var fire = bullets.spawn.bind(_, _, Player, FlxColor.YELLOW, 0, Homing, 700);
		fire(x + BulletOffsetX, y + BulletOffsetY);
		fire(x + frameWidth - BulletOffsetX, y + BulletOffsetY);

		FlxG.sound.play('assets/sounds/pew.wav', 0.7);
		y += Kickback;
	}

	public function startFiring() {
		if (firing) {
			return;
		}
		fireTimer.start(FireRate, shoot, 0);
		firing = true;
	}

	override function kill() {
		#if inv
		return;
		#end

		if (!alive) {
			return;
		}

		super.kill();

		exhaust1.kill();
		exhaust2.kill();
		fireTimer.cancel();

		FlxG.sound.play('assets/sounds/lose.wav');
		FlxG.camera.shake(0.03, 1);

		var gibs = new FlxEmitter();
		gibs.alpha.start.set(1);
		gibs.alpha.end.set(0);
		gibs.scale.start.set(new FlxPoint(1.5, 1.5), new FlxPoint(2.5, 2.5));
		gibs.scale.end.set(new FlxPoint(0.1, 0.1), new FlxPoint(0.2, 0.2));
		gibs.velocity.set(0, 0, 10, 10, 0, 0, 10, 10);
		gibs.lifespan.set(20);
		gibs.angle.set(0, 360, 0, 360);
		gibs.x = x;
		gibs.y = y;
		for (i in 0...40) {
			var gib = new FlxParticle();
			gib.loadGraphic("assets/images/ship.png", true, 4, 4);
			gib.animation.frameIndex = i % gib.animation.frames;
			gibs.add(gib);
		}
		gibs.start();
		FlxG.state.add(gibs);

		FlxG.camera.follow(this);
		FlxG.camera.followLerp = 0.5;
		FlxTween.tween(FlxG.camera, {zoom: 2}, 3);
		var almostBlack = FlxColor.BLACK;
		almostBlack.alphaFloat = 0.9;
		FlxG.camera.fade(almostBlack, 10);
	}

	override function hurt(damage:Float) {
		if (!solid) {
			return;
		}
		super.hurt(damage);
	}
}
