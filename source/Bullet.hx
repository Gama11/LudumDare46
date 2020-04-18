class Bullet extends FlxSprite implements ITeam {
	static inline final MaxVelocity = 500;

	public var team(default, null):Team = Enemy;
	public var damage(default, null) = 1;

	public function new() {
		super();
		maxVelocity.set(MaxVelocity, MaxVelocity);
		makeGraphic(2, 4);
	}

	public function init(x, y, team) {
		reset(x, y);
		this.team = team;
		velocity.y = -MaxVelocity;
	}
}
