import Pickup.PickupType;
import flixel.addons.display.FlxStarField.FlxStarField2D;
import openfl.filters.ShaderFilter;

class PlayState extends FlxState {
	public static var FirstWaveBeaten = false;
	public static final IntroDuration = 3;
	public static var Difficulty(default, null):Float;

	var player:Player;
	var bullets:Bullets;
	var enemies:Enemies;
	var pickups:Pickups;
	var cursor:FlxSprite;
	var ui:UI;

	var score:Int = 0;
	var pickupChance:Float = 0;
	var gameStarted = false;
	var gameEnded = false;

	override public function create() {
		if (FlxG.sound.music == null) { // we came from the menu
			FlxG.camera.zoom = 0.1;
		}
		FlxCamera.defaultCameras = [FlxG.camera];
		FlxG.sound.playMusic("assets/music/music.wav");
		FlxG.sound.music.volume = 0;
		FlxG.sound.music.fadeIn(3);
		FlxG.sound.defaultSoundGroup.volume = 0.3;
		FlxG.timeScale = 1;
		Difficulty = 1;

		bgColor = 0x222222;

		var starField = new FlxStarField2D();
		starField.starVelocityOffset.set(0, 1);

		bullets = new Bullets();
		pickups = new Pickups();
		enemies = new Enemies(bullets, increaseLevel);

		player = new Player(bullets);
		player.screenCenter();
		player.active = false;
		player.y = FlxG.height + 200;

		cursor = new FlxSprite("assets/images/target2.png");

		var uiCamera = FlxG.cameras.add(new FlxCamera());
		ui = new UI(player);
		ui.cameras = [uiCamera];

		add(starField);
		add(pickups);
		add(bullets);
		add(enemies);
		add(cursor);
		add(player.exhaust1);
		add(player.exhaust2);
		add(player);
		add(ui);

		FlxG.mouse.visible = false;

		// FlxG.debugger.visible = true;
		FlxG.console.registerClass(Player);

		FlxTween.tween(FlxG.camera, {zoom: 1}, 1, {ease: FlxEase.expoIn});
		new FlxTimer().start(IntroDuration, function(_) {
			ui.endIntro(() -> {
				startGame();
			});
		});
		new FlxTimer().start(1, _ -> FlxG.sound.play("assets/sounds/intro.wav"));

		var skip = FirstWaveBeaten || #if debug true #else false #end;
		if (skip) {
			skipIntro();
		}

		// FlxG.camera.setFilters([new ShaderFilter(new CameraShader())]);
	}

	function increaseLevel() {
		Difficulty += 0.1;
		ui.updateDifficulty(Difficulty);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		FlxG.overlap(bullets, enemies, onBulletHit);
		FlxG.overlap(bullets, player, onBulletHit);
		FlxG.overlap(pickups, player, onCollectPickup);

		var boss = enemies.boss;
		if (boss != null && boss.alive) {
			var beams = boss.beams;
			/* if (beams != null) {
					for (beam in beams) {
						if (beam.alpha == 1 && FlxG.pixelPerfectOverlap(beam, player)) {
							player.hurt(1);
						}
					}
				}
				if (FlxG.pixelPerfectOverlap(boss, player)) {
					player.hurt(1);
			}*/

			if (FlxG.overlap(boss, player)) {
				player.hurt(1);
			}

			if (beams != null) {
				var screenCenter = new FlxPoint(FlxG.width, FlxG.height).scale(0.5);
				for (beam in beams) {
					if (!beam.solid) {
						continue;
					}

					var offset = 0;
					var a1 = FlxAngle.wrapAngle(beam.angle) + offset;
					var a2 = FlxAngle.wrapAngle(beam.angle + 180) + offset;

					var playerBoss = FlxAngle.wrapAngle(FlxAngle.angleBetweenPoint(player, screenCenter, true));
					var d1 = Std.int(Math.abs(playerBoss - a1));
					var d2 = Std.int(Math.abs(playerBoss - a2));
					var minDelta = Std.int(Math.min(d1, d2));

					// FlxG.watch.addQuick("playerBoss", playerBoss);
					// FlxG.watch.addQuick(beams.members.indexOf(beam) + "", '$d1, $d2');

					if (minDelta < 5) {
						player.hurt(1);
						break;
					}
				}
			}
		}

		cursor.x = FlxG.mouse.x - cursor.frameWidth / 2;
		cursor.y = FlxG.mouse.y - cursor.frameHeight / 2 + 10;
		cursor.color = if (player.charge < 1) FlxColor.WHITE else FlxColor.RED;

		if (FlxG.keys.justPressed.R) {
			FlxG.resetState();
		}
		if (FlxG.keys.justPressed.S) {
			skipIntro();
		}
		#if debug
		if (FlxG.keys.justPressed.D) {
			player.kill();
		}
		if (FlxG.keys.justPressed.I) {
			player.health = 99999;
		}
		if (FlxG.keys.justPressed.T) {
			FlxG.camera.filtersEnabled = !FlxG.camera.filtersEnabled;
		}
		if (FlxG.keys.justPressed.ESCAPE) {
			FlxG.switchState(new MenuState());
		}
		if (FlxG.keys.justPressed.H) {
			FlxG.debugger.drawDebug = !FlxG.debugger.drawDebug;
		}
		if (FlxG.keys.justPressed.S) {
			FlxG.timeScale = if (FlxG.timeScale == 1) 0.1 else 1;
		}
		if (FlxG.keys.justPressed.U) {
			increaseLevel();
		}
		if (FlxG.keys.justPressed.FOUR) {
			onCollectPickup(new Pickup().init(0, 0, DoubleShot), player);
		}
		#end

		if (gameStarted) {
			if (!player.alive && !gameEnded) {
				ui.endGame();
				gameEnded = true;
				if (FlxG.save.data.highscore == null || FlxG.save.data.highscore < score) {
					FlxG.save.data.highscore = score;
				}
				var deaths:Null<Int> = FlxG.save.data.deaths;
				if (deaths == null) {
					deaths = 0;
				}
				FlxG.save.data.deaths = deaths + 1;
			}

			if (Difficulty >= 1.1) {
				if (FlxG.random.bool(pickupChance)) {
					pickupChance = 0;
					var type = FlxG.random.getObject(PickupType.createAll());
					pickups.recycle(Pickup, Pickup.new).init(FlxG.random.int(0, FlxG.width - 10), -10, type);
				} else {
					pickupChance += 0.001 * elapsed * 60;
				}
			}

			for (bullet in bullets) {
				if (bullet.type == Homing) {
					var minDistance = Math.POSITIVE_INFINITY;
					var target = null;
					for (enemy in enemies) {
						if (!enemy.exists || !enemy.alive || enemy.killAnimation || enemy.y < 0) {
							continue;
						}
						var distance = FlxMath.distanceBetween(enemy, bullet);
						if (distance < minDistance && distance < Bullet.HomingDistance) {
							minDistance = distance;
							target = enemy;
						}
					}
					bullet.target = target;
				}
			}
		}
	}

	function onBulletHit(bullet:Bullet, object:ITeam) {
		if (bullet.team != object.team) {
			var object:FlxSprite = cast object;
			var wasAlive = object.alive;

			object.hurt(bullet.damage);

			if (bullet.team == Player && wasAlive && !object.alive && !gameEnded) {
				var enemy:Enemy = cast object;
				increaseScore(enemy.score);
			}

			bullet.kill();
		}
	}

	var slowDownFadeTween:FlxTween;

	function onCollectPickup(pickup:Pickup, player:Player) {
		pickup.solid = false;

		function tween(target, ?f:() -> Void) {
			FlxTween.tween(pickup, {x: target, y: 0}, 0.5, {
				ease: FlxEase.quadIn,
				onComplete: _ -> {
					pickup.kill();
					if (f != null) {
						f();
					}
				}
			});
		}

		switch pickup.type {
			case Score:
				FlxG.sound.play("assets/sounds/coin.wav");
				tween(FlxG.width - 80, function() {
					increaseScore(pickup.score);
				});

			case Bomb:
				for (bullet in bullets) {
					bullet.kill();
				}
				FlxG.camera.shake();
				FlxG.sound.play("assets/sounds/bomb.wav");
				pickup.kill();
				for (enemy in enemies) {
					enemy.active = false;
				}
				new FlxTimer().start(2, function(_) {
					for (enemy in enemies) {
						enemy.active = true;
					}
				});

			case Slowdown:
				if (slowDownFadeTween != null) {
					slowDownFadeTween.cancel();
				}
				tween(80, () -> {
					ui.slowdownIcon.alpha = 1;
					FlxG.timeScale = 0.7;
					FlxG.sound.play("assets/sounds/slowdown.wav");
					var duration = 3;
					var fadeOut = 1;
					new FlxTimer().start(duration, function(_) {
						FlxTween.tween(FlxG, {timeScale: 1}, fadeOut);
					});
					slowDownFadeTween = FlxTween.tween(ui.slowdownIcon, {alpha: 0}, duration + fadeOut);
				});

			case DoubleShot:
				FlxG.sound.play("assets/sounds/powerup.wav");
				player.startDoubleShot();
				pickup.kill();
		}
	}

	function skipIntro() {
		ui.skipIntro();
		startGame();
	}

	function startGame() {
		gameStarted = true;
		player.active = true;
		player.dodgeRoll();

		new FlxTimer().start(Player.RollDuration, function(_) {
			player.startFiring();
			enemies.startSpawning();
		});
	}

	function increaseScore(amount:Int) {
		score += Std.int(amount * Difficulty);
		ui.updateScore(score);
	}
}
