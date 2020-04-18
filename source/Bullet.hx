class Bullet extends FlxSprite implements ITeam {
	static inline final MaxVelocity = 500;

	public var team(default, null):Team = Enemy;
	public var damage(default, null) = 1;

	var scaleTween:FlxTween;

	public function new() {
		super();
		maxVelocity.set(MaxVelocity, MaxVelocity);
		makeGraphic(3, 8);
	}

	public function init(x, y, team) {
		reset(x, y);
		this.team = team;
		velocity.y = -MaxVelocity;
		scale.set(0.1, 0.1);
		if (scaleTween != null) {
			scaleTween.cancel();
		}
		scaleTween = FlxTween.tween(scale, {x: 1, y: 1}, 0.1, {ease: FlxEase.cubeIn});
	}
}
