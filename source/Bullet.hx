enum BulletType {
	Normal;
	Wiggle;
}

class Bullet extends FlxSprite implements ITeam {
	static inline final WiggleStrength = 20;

	public var team(default, null):Team = Enemy;
	public var damage(default, null) = 1;

	var scaleTween:FlxTween;
	var wiggleTween:FlxTween;
	var type:BulletType;

	public function new() {
		super();
		makeGraphic(8, 4);
	}

	public function init(x, y, team, color, angle, type, speed) {
		reset(x, y);

		angle -= 90;
		this.team = team;
		this.color = color;
		this.angle = angle;

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
		super.update(elapsed);
		if (y > 1000 || y < -200) {
			exists = false;
		}
	}
}
