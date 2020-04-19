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

	public function new() {
		super();
		makeGraphic(8, Width);
	}

	public function init(x, y, team, color, angle:Float, type, speed) {
		reset(x, y);

		angle -= 90;
		this.team = team;
		this.color = color;
		this.angle = angle;
		this.type = type;

		velocity.copyFrom(FlxVelocity.velocityFromAngle(angle, speed));

		scale.set(0.1, 0.1);
		if (scaleTween != null) {
			scaleTween.cancel();
		}
		scaleTween = FlxTween.tween(scale, {x: 1, y: 1}, 0.1, {ease: FlxEase.cubeIn});

		if (wiggleTween != null) {
			wiggleTween.cancel();
		}
		if (type == Wiggle) {
			velocity.x = -WiggleStrength;
			wiggleTween = FlxTween.tween(velocity, {x: WiggleStrength}, 0.1, {type: PINGPONG});
		}
	}

	override function update(elapsed:Float) {
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

		super.update(elapsed);
	}
}
