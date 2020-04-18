import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxGlitchEffect;

class UI extends FlxSpriteGroup {
	static final ScaleIncreasePercentage = 0.5;

	var heart:FlxSprite;
	var healthCounter:FlxText;
	var scoreText:FlxText;

	var effectSprite:FlxEffectSprite;
	var instructions:FlxText;
	var thumps:Array<FlxTween> = [];

	public function new() {
		super();

		heart = new FlxSprite(10, 10, AssetPaths.heart__png);
		heart.scale.scale(2);
		add(heart);

		healthCounter = new FlxText(heart.x + heart.frameWidth + 12, 0, "1", 22);
		healthCounter.color = FlxColor.RED;
		add(healthCounter);

		function thump(object:FlxSprite) {
			var scale = object.scale.x + object.scale.x * ScaleIncreasePercentage;
			var options = {
				type: FlxTweenType.LOOPING,
				ease: FlxEase.expoIn
			};
			thumps.push(FlxTween.tween(object.scale, {x: scale, y: scale}, 1, options));
		}

		thump(heart);
		thump(healthCounter);

		var message = new FlxText(0, 0, "You're on your last life, pilot\n - better make the most of it!", 36);
		message.color = FlxColor.GRAY;
		effectSprite = new FlxEffectSprite(message, [new FlxGlitchEffect(4, 4)]);
		effectSprite.setPosition(40, FlxG.height - 120);
		add(effectSprite);

		var instructionMessage = "Mouse to move.\nWell, barely - your engines are damaged.\nRight Click to Dodge Roll.\nHold Space to Lock Position.\nDon't die.";
		instructions = new FlxText(-1000, FlxG.height / 2 - 50, instructionMessage, 24);
		instructions.borderStyle = OUTLINE;
		instructions.borderColor = FlxColor.WHITE;
		instructions.alignment = CENTER;
		instructions.color = FlxColor.BLACK;
		add(instructions);

		scoreText = new FlxText(320, 0, 0, "Score: 0", 16);
		scoreText.fieldWidth = FlxG.width;
		scoreText.alignment = CENTER;
		add(scoreText);

		for (member in this) {
			member.scrollFactor.set();
		}
	}

	public function endIntro(callback:() -> Void) {
		FlxTween.tween(effectSprite, {alpha: 0}, 1, {
			onComplete: function(_) {
				FlxTween.tween(instructions, {x: 25}, 0.1, {
					onComplete: function(_) {
						new FlxTimer().start(6, function(_) {
							FlxTween.tween(instructions, {x: 1000}, 0.1);
							callback();
						});
					}
				});
			}
		});
	}

	public function skipIntro() {
		effectSprite.kill();
		instructions.kill();
	}

	public function endGame() {
		function accelerate(s:FlxSprite) {
			s.acceleration.y = FlxG.random.int(550, 600);
			s.acceleration.x = FlxG.random.int(50, 100);
			s.angularVelocity = FlxG.random.int(20, 40);
		}
		function makePiece(n:Int) {
			var piece = new FlxSprite('assets/images/heart_piece_$n.png');
			piece.x = heart.x;
			piece.y = heart.y;
			piece.scale.scale(2);
			accelerate(piece);
			add(piece);
			return piece;
		}

		makePiece(1);
		makePiece(2).x += 10;

		healthCounter.text = "0";
		healthCounter.moves = true;
		accelerate(healthCounter);

		heart.visible = false;

		for (thump in thumps) {
			thump.cancel();
		}

		FlxTween.tween(scoreText, {x: 0, y: FlxG.height / 2 - 150}, 0.3, {
			onComplete: _ -> {
				new FlxTimer().start(1, function(_) {
					scoreText.text = "Final " + scoreText.text;
					FlxG.sound.play("assets/sounds/final.wav");
					new FlxTimer().start(1, function(_) {
						new FlxTimer().start(1, function(_) {
							var deaths = FlxG.save.data.deaths;
							if (deaths == null) {
								return;
							}
							scoreText.text += "\nDeaths: " + deaths;
							FlxG.sound.play("assets/sounds/final3.wav");
						});
						var highscore = FlxG.save.data.highscore;
						if (highscore == null) {
							return;
						}
						scoreText.text += "\nHighscore: " + highscore;
						FlxG.sound.play("assets/sounds/final2.wav");
					});
				});
			},
			onUpdate: function(tween) {
				scoreText.size = Std.int(16 + tween.percent * (64 - 16));
			}
		});
	}

	public function updateScore(score:Int) {
		scoreText.text = 'Score: $score';
		var scale = 3;
		scoreText.scale.set(scale, scale);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		var scale = scoreText.scale.x;
		if (scale > 1) {
			scale -= 0.1;
			scoreText.scale.set(scale, scale);
		}
	}
}
