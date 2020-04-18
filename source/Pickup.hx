class Pickup extends FlxSprite {
	public var score(default, null):Int = 1;

	var tween:FlxTween;

	public function new() {
		super("assets/images/pickup.png");
	}

	public function init(x, y) {
		reset(x, y);
		scale.set(1, 1);
		velocity.y = FlxG.random.int(100, 500);
		solid = true;
	}

	override function kill() {
		solid = false;
		FlxTween.tween(this, {x: FlxG.width - 80, y: 0}, 0.5, {
			ease: FlxEase.quadIn,
			onComplete: _ -> {
				exists = false;
			}
		});
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (y > FlxG.height + 20) {
			exists = false;
		}
	}
}
