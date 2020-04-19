import flixel.addons.display.FlxStarField.FlxStarField2D;
import openfl.filters.ShaderFilter;

class PlayState extends FlxState {
	public static var FirstWaveBeaten = false;
	public static final IntroDuration = 3;

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
		FlxCamera.defaultCameras = [FlxG.camera];

		bgColor = 0x222222;
		FlxG.camera.zoom = 0.1;

		var starField = new FlxStarField2D();
		starField.starVelocityOffset.set(0, 1);

		bullets = new Bullets();
		pickups = new Pickups();
		enemies = new Enemies(bullets);

		player = new Player(bullets);
		player.screenCenter();

		cursor = new FlxSprite("assets/images/target2.png");

		var uiCamera = FlxG.cameras.add(new FlxCamera());
		ui = new UI();
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
		// FlxG.debugger.drawDebug = true;
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

		FlxG.camera.setFilters([new ShaderFilter(new CameraShader())]);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		FlxG.overlap(bullets, enemies, onBulletHit);
		FlxG.overlap(bullets, player, onBulletHit);
		FlxG.overlap(pickups, player, onCollectPickup);

		cursor.x = FlxG.mouse.x - cursor.frameWidth / 2;
		cursor.y = FlxG.mouse.y - cursor.frameHeight / 2 + 10;
		cursor.alpha = player.canRoll ? 1 : 0.2;

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

			if (FlxG.random.bool(pickupChance)) {
				pickupChance = 0;
				pickups.recycle(Pickup, Pickup.new).init(FlxG.random.int(0, FlxG.width - 10), -10);
			} else {
				pickupChance += 0.01;
			}

			for (bullet in bullets) {
				if (bullet.type == Homing) {
					var minDistance = Math.POSITIVE_INFINITY;
					var target = null;
					for (enemy in enemies) {
						if (!enemy.exists || enemy.y < 0) {
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
			object.hurt(bullet.damage);

			if (bullet.team == Player && !object.alive && !gameEnded) {
				var enemy:Enemy = cast object;
				increaseScore(enemy.score);
			}
		}
	}

	function onCollectPickup(pickup:Pickup, player:Player) {
		increaseScore(pickup.score);
		pickup.kill();
		FlxG.sound.play("assets/sounds/coin.wav");
	}

	function skipIntro() {
		ui.skipIntro();
		startGame();
	}

	function startGame() {
		gameStarted = true;
		player.startFiring();
		enemies.startSpawning();
	}

	function increaseScore(amount:Int) {
		score += amount;
		ui.updateScore(score);
	}
}
