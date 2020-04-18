class Bullet extends FlxSprite implements ITeam {
	static inline final Velocity = 500;
	static inline final WiggleStrength = 20;

	public var team(default, null):Team = Enemy;
	public var damage(default, null) = 1;

	var scaleTween:FlxTween;
	var wiggleTween:FlxTween;

	public function new() {
		super();
		makeGraphic(3, 8);
	}

	public function init(x, y, team, color) {
		reset(x, y);
		this.team = team;
		this.color = color;
		velocity.y = -Velocity;
		scale.set(0.1, 0.1);
		if (scaleTween != null) {
			scaleTween.cancel();
		}
		if (wiggleTween != null) {
			wiggleTween.cancel();
		}

		scaleTween = FlxTween.tween(scale, {x: 1, y: 1}, 0.1, {ease: FlxEase.cubeIn});

		velocity.x = -WiggleStrength;
		wiggleTween = FlxTween.tween(velocity, {x: WiggleStrength}, 0.1, {type: PINGPONG});
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (!isOnScreen()) {
			kill();
		}
	}
}
