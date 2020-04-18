import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxGlitchEffect;

class UI extends FlxSpriteGroup {
	static final ScaleIncreasePercentage = 0.4;

	var effectSprite:FlxEffectSprite;

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

		var message = new FlxText(0, 0, "You're on your last life, pilot\n - better make the most of it!", 36);
		message.color = FlxColor.GRAY;
		effectSprite = new FlxEffectSprite(message, [new FlxGlitchEffect(4, 4)]);
		effectSprite.setPosition(40, FlxG.height - 120);
		add(effectSprite);
	}

	public function endIntro() {
		FlxTween.tween(effectSprite, {alpha: 0}, 3);
	}
}
