class UI extends FlxSpriteGroup {
	static final ScaleIncreasePercentage = 0.3;

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

		function tween(object:FlxSprite) {
			var scale = object.scale.x + object.scale.x * ScaleIncreasePercentage;
			FlxTween.tween(object.scale, {x: scale, y: scale}, 1, {
				type: LOOPING,
				ease: FlxEase.expoIn
			});
		}

		tween(heart);
		tween(healthCounter);
	}
}
