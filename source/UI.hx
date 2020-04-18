class UI extends FlxSpriteGroup {
	static final ScaleIncreasePercentage = 0.4;

	public function new() {
		super();

		var heart = new FlxSprite(10, 10, AssetPaths.heart__png);
		heart.scale.scale(2);
		add(heart);

		var healthCounter = new FlxText(heart.x + heart.frameWidth + 12, 0, "1", 22);
		healthCounter.color = FlxColor.RED;
		add(healthCounter);

		for (member in this) {
			member.scrollFactor.set();
		}

		function thump(object:FlxSprite) {
			var scale = object.scale.x + object.scale.x * ScaleIncreasePercentage;
			var options = {
				type: FlxTweenType.LOOPING,
				ease: FlxEase.expoIn
			};
			FlxTween.tween(object.scale, {x: scale, y: scale}, 1, options);
		}

		thump(heart);
		thump(healthCounter);
	}
}
