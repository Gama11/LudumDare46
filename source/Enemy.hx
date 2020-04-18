class Enemy extends FlxSprite implements ITeam {
	public var team(default, null):Team = Enemy;

	public function new() {
		super();
		makeGraphic(10, 10);
	}

	public function init(x, y) {
		reset(x, y);
	}
}
