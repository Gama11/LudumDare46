enum PickupType {
	Score;
	Bomb;
	Slowdown;
}

class Pickup extends FlxSprite {
	public var score(default, null):Int = 1;
	public var type(default, null):PickupType;

	var tween:FlxTween;

	public function new() {
		super();
	}

	public function init(x, y, type) {
		this.type = type;
		reset(x, y);
		scale.set(1, 1);
		angularVelocity = 50;
		velocity.y = FlxG.random.int(200, 300);
		solid = true;

		switch type {
			case Score:
				loadGraphic("assets/images/pickup.png");
			case Bomb:
				loadGraphic("assets/images/X.png");
			case Slowdown:
				loadGraphic("assets/images/slowdown.png");
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (y > FlxG.height + 20) {
			exists = false;
		}
	}
}
