import flixel.addons.display.FlxStarField.FlxStarField2D;
import flixel.addons.effects.chainable.*;

class MenuState extends FlxState {
	var effectSprite:FlxSprite;
	var effectSprite2:FlxSprite;
	var transitioning = false;

	override function create() {
		super.create();

		var starField = new FlxStarField2D();
		starField.starVelocityOffset.set(0, 1);
		add(starField);

		var message = new FlxText(0, 0, "The Little Ship\n   That Could", 75);
		message.color = FlxColor.GRAY;
		effectSprite = new FlxEffectSprite(message, [new FlxGlitchEffect(4, 4)]);

		add(effectSprite);

		var message = new FlxText(0, 0, "[Click To Start]", 30);
		message.color = FlxColor.GRAY;
		effectSprite2 = new FlxEffectSprite(message, [new FlxGlitchEffect(4, 4)]);
		add(effectSprite2);
		effectSprite2.alpha = 0;
		FlxTween.tween(effectSprite2, {alpha: 1}, 1.5, {
			type: PINGPONG,
			onComplete: tween -> {
				if (tween.backward && !transitioning) {
					FlxG.sound.play("assets/sounds/menu_fade.wav");
				}
			}
		});

		FlxG.mouse.load("assets/images/target2.png");
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxG.mouse.justPressed && !transitioning) {
			FlxG.sound.play("assets/sounds/start.wav", 0.3);
			transitioning = true;
			FlxG.camera.fade(FlxColor.BLACK, 3, () -> {
				FlxG.switchState(new PlayState());
			});
			FlxTween.tween(FlxG.camera, {zoom: 0.01}, 3);
		}

		effectSprite.screenCenter();
		effectSprite.y -= 200;

		effectSprite2.screenCenter();
		effectSprite2.y += 200;
	}
}
