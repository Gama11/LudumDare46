import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxGlitchEffect;

class UI extends FlxSpriteGroup {
	static final ScaleIncreasePercentage = 0.4;

	var effectSprite:FlxEffectSprite;
	var instructions:FlxText;

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

		instructions = new FlxText(-1000, FlxG.height / 2, "Mouse to move. Right Click to Dodge Roll. Don't die.", 24);
		instructions.borderStyle = OUTLINE;
		instructions.borderColor = FlxColor.WHITE;
		instructions.color = FlxColor.BLACK;
		add(instructions);
	}

	public function endIntro(callback:()->Void) {
		FlxTween.tween(effectSprite, {alpha: 0}, 1, {
			onComplete: function(_) {
				FlxTween.tween(instructions, {x: 25}, 0.1, {
					onComplete: function(_) {
						new FlxTimer().start(3, function(_) {
							FlxTween.tween(instructions, {x: 1000}, 0.1);
							callback();
						});
					}
				});
			}
		});
	}
}
