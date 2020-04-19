import flixel.ui.FlxBar;

enum EnemyType {
	Basic(xDir:Int);
	Basic2;
	Basic3;
	Boss;
}

class Enemy extends FlxSprite implements ITeam {
	static final BossSize = 300;

	public var team(default, null):Team = Enemy;
	public var score(default, null):Int;
	public var beams(default, null):FlxTypedGroup<FlxSprite>;
	public var killAnimation(default, null) = false;

	final fireTimer = new FlxTimer();
	final bullets:Bullets;
	var type:EnemyType;
	var waitUntilNextVolley:Int = 0;
	var shot:Int = 0;
	var maxHealth:Float;

	var healthBar:FlxBar;

	public function new(bullets) {
		super();
		this.bullets = bullets;
	}

	public function init(x, y, type) {
		if (type == Boss) {
			y = -BossSize;
		}
		reset(x, y);

		this.type = type;
		shot = 0;
		angle = 0;
		angularVelocity = 0;
		angularAcceleration = 0;
		killAnimation = false;
		fireTimer.cancel();
		color = FlxColor.WHITE;
		scale.set(1, 1);
		antialiasing = false;
		alpha = 1;
		offset.set();
		solid = true;
		lockY = null;

		switch type {
			case Basic(xDir):
				velocity.y = 150;
				velocity.x = 50 * xDir;
				score = 2;
				loadGraphic("assets/images/invader1.png");
				health = maxHealth = 4;
				scale.set(2, 2);
				fireTimer.start(0.2, _ -> tripleShot(), 0);
				waitUntilNextVolley = FlxG.random.int(0, 5);

			case Basic2:
				velocity.y = 150;
				score = 3;
				loadGraphic("assets/images/invader2.png");
				scale.set(2, 2);
				health = maxHealth = 6;
				color = FlxColor.BLUE;
				fireTimer.start(0.03, _ -> circularShot(), 0);

			case Basic3:
				velocity.y = 250;
				score = 1;
				loadGraphic("assets/images/invader3.png");
				health = maxHealth = 3;
				scale.set(2, 2);
				color = FlxColor.ORANGE;
				fireTimer.start(0.4, _ -> straightShot(), 0);

			case Boss:
				velocity.y = 150;
				score = 25;
				health = maxHealth = 120;
				makeGraphic(BossSize, BossSize, FlxColor.TRANSPARENT);
				FlxSpriteUtil.drawCircle(this);
				color = FlxColor.MAGENTA;
				width *= 0.7;
				height *= 0.7;
				centerOffsets();
				screenCenter(X);
				antialiasing = true;
		}

		health *= PlayState.Difficulty;
		maxHealth *= PlayState.Difficulty;

		if (type == Boss) {
			healthBar = new FlxBar(0, 0, LEFT_TO_RIGHT, 200, 20, this, "health", 0, maxHealth);
			healthBar.createFilledBar(FlxColor.BLACK, color, true, FlxColor.BLACK);
			healthBar.screenCenter(X);
		}
	}

	var lockY:Null<Float> = null;

	override function update(elapsed:Float) {
		if (y > 1000) {
			exists = false;
		}

		if (type == Boss && y > FlxG.height / 2 - frameHeight / 2 && velocity.y != 0) {
			velocity.set();
			lockY = y;
			beam();
		}

		if (type == Boss && lockY != null) {
			y = FlxMath.lerp(y, lockY, 0.5);
		}

		if (beams != null) {
			beams.update(elapsed);
		}
		if (healthBar != null) {
			healthBar.update(elapsed);
			healthBar.y = getMidpoint().y;
		}

		super.update(elapsed);
	}

	override function draw() {
		if (beams != null) {
			beams.draw();
		}

		super.draw();

		if (healthBar != null) {
			healthBar.draw();
		}
	}

	function tripleShot() {
		if (!active) {
			return;
		}
		if (waitUntilNextVolley > 0) {
			waitUntilNextVolley--;
			return;
		}

		var angleOffset = 180;
		var deltaAngle = 20;
		var y = y + frameHeight - 2;
		var x = x + frameWidth / 2;

		var fire = bullets.spawn.bind(x - Bullet.Width / 2, y, Enemy, FlxColor.GREEN, _, Normal, 300, false);
		fire(angleOffset - deltaAngle);
		fire(angleOffset);
		fire(angleOffset + deltaAngle);

		shot++;
		if (shot > 5) {
			waitUntilNextVolley = 6;
			shot = 0;
		}
	}

	var lastShotAngle = 0.0;

	function circularShot() {
		if (!active) {
			return;
		}
		var shotAngle = FlxAngle.wrapAngle(lastShotAngle + 5);
		bullets.spawn(x + 20, y + 10, Enemy, color, shotAngle, Normal, 150, false);
		lastShotAngle = shotAngle;
	}

	function straightShot() {
		if (!active) {
			return;
		}
		bullets.spawn(x + frameWidth / 2 - 2, y + frameHeight - 5, Enemy, color, 180, Wiggle, 150, false);
	}

	function beam() {
		FlxG.sound.play("assets/sounds/charge_beam.wav", () -> {
			for (beam in beams) {
				beam.alpha = 1;
				beam.solid = true;
			}
		});
		beams = new FlxTypedGroup<FlxSprite>();

		var beamWidth = 20;
		function makeBeam() {
			var beam = new FlxSprite();
			var margin = 400;
			beam.makeGraphic(beamWidth, FlxG.width + margin, color);
			beam.alpha = 0.2;
			beam.screenCenter();
			beam.angle += 45;
			beam.solid = false;
			beam.antialiasing = true;
			FlxTween.tween(beam, {
				angularVelocity: if (PlayState.Difficulty > 1.5) 25 else 40
			}, 3, {
				ease: FlxEase.expoIn
			});
			beams.add(beam);
			return beam;
		}
		makeBeam();
		makeBeam().angle += 90;

		/* if (PlayState.Difficulty > 1.5) {
				makeBeam().angle += 45;
			}
			if (PlayState.Difficulty > 2.0) {
				makeBeam().angle += 45 + 90;
		}*/

		fireTimer.start(5, function(_) {
			for (beam in beams) {
				FlxTween.tween(beam, {angularVelocity: -beam.angularVelocity}, 2);
			}
			FlxG.sound.play("assets/sounds/reverse.wav");
		}, 0);
	}

	override function kill() {
		if (killAnimation) {
			return;
		}
		killAnimation = true;
		alive = false;
		solid = false;
		beams = null;
		healthBar = null;
		fireTimer.cancel();
		FlxG.sound.play("assets/sounds/explode_enemy.wav");
		FlxG.camera.shake(0.005, 0.2);
		angularAcceleration = 700;
		velocity.set();
		FlxTween.tween(scale, {x: 0, y: 0}, 1, {onComplete: _ -> exists = false});
	}

	override function hurt(damage:Float) {
		if (velocity.y != 0 && type == Boss) {
			return;
		}

		super.hurt(damage);

		if (type != Boss) {
			alpha = Math.max(health / maxHealth, 0.2);
		} else {
			y -= 3;
		}
	}
}
