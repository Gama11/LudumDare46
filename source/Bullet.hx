enum BulletType {
	Normal;
	Wiggle;
	Homing;
}

class Bullet extends FlxSprite implements ITeam {
	public static final HomingDistance = 500;

	public static final Width = 4;
	static final WiggleStrength = 20;

	public var team(default, null):Team = Enemy;
	public var damage(default, null) = 1;
	public var type(default, null):BulletType;

	public var target:FlxSprite;

	var scaleTween:FlxTween;
	var wiggleTween:FlxTween;
	var rainbowTween:FlxTween;
	var rainbow:Bool;
	var lifetime = 0.0;

	public function new() {
		super();
		makeGraphic(8, Width);
	}

	public function init(x, y, team, color, angle:Float, type, speed, rainbow) {
		reset(x, y);

		angularVelocity = 0;
		angularAcceleration = 0;
		angle -= 90;
		lifetime = 0;
		alpha = 1;
		this.team = team;
		this.color = color;
		this.angle = angle;
		this.type = type;
		this.rainbow = rainbow;
		color = FlxColor.WHITE;

		velocity.copyFrom(FlxVelocity.velocityFromAngle(angle, speed));

		scale.set(0.1, 0.1);
		scaleTween = FlxTween.tween(scale, {x: 1, y: 1}, 0.1, {ease: FlxEase.cubeIn});

		if (type == Wiggle) {
			angularAcceleration = FlxG.random.int(20, 30) * FlxG.random.sign();
		}
		/* if (type == Wiggle) {
			velocity.x = -WiggleStrength;
			wiggleTween = FlxTween.tween(velocity, {x: WiggleStrength}, 0.1, {type: PINGPONG});
		}*/
		/* if (rainbow) {
			rainbowTween = FlxTween.color(this, 3, FlxColor.WHITE, FlxColor.BLACK, {type: PINGPONG});
		}*/
	}

	override function update(elapsed:Float) {
		lifetime += elapsed;

		if (y > FlxG.height + 20 || y < -20) {
			exists = false;
		}

		if (type == Homing && target != null) {
			var vec:FlxVector = velocity;
			var angleBetween = FlxAngle.angleBetween(this, target, true);
			if (y > target.y) {
				angle = FlxMath.lerp(angle, angleBetween, 0.1);
				velocity = FlxVelocity.velocityFromAngle(angle, vec.length);
			}
		}

		if (rainbow) {
			color = PlayState.rainbowColor;
		}

		if (type == Wiggle) {
			if (lifetime < 5) {
				var vec:FlxVector = velocity;
				velocity.copyFrom(FlxVelocity.velocityFromAngle(angle, vec.length));
			} else {
				angularAcceleration = 0;
				angularVelocity = 0;
				alpha -= elapsed / 2;
				if (alpha < 0.5) {
					kill();
				}
			}
		}

		super.update(elapsed);
	}

	override function kill() {
		super.kill();

		if (rainbowTween != null) {
			rainbowTween.cancel();
		}
		if (wiggleTween != null) {
			wiggleTween.cancel();
		}
		if (scaleTween != null) {
			scaleTween.cancel();
		}
	}
}
