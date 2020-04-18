import flixel.addons.display.FlxStarField.FlxStarField2D;

class PlayState extends FlxState {
	public static final IntroDuration = 3;

	var player:Player;
	var bullets:Bullets;
	var enemies:Enemies;
	var cursor:FlxSprite;
	var ui:UI;

	override public function create() {
		FlxCamera.defaultCameras = [FlxG.camera];

		bgColor = 0x222222;
		FlxG.camera.zoom = 0.1;

		var starField = new FlxStarField2D();
		starField.starVelocityOffset.set(0, 1);

		bullets = new Bullets();
		enemies = new Enemies(bullets);

		player = new Player(bullets);
		player.screenCenter();

		cursor = new FlxSprite("assets/images/target.png");

		var uiCamera = FlxG.cameras.add(new FlxCamera());
		ui = new UI();
		ui.cameras = [uiCamera];

		add(starField);
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
				player.startFiring();
				enemies.startSpawning();
			});
		});
		new FlxTimer().start(1, _ -> FlxG.sound.play("assets/sounds/intro.wav"));

		#if debug
		skipIntro();
		#end
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		FlxG.overlap(bullets, enemies, onBulletHit);
		FlxG.overlap(bullets, player, onBulletHit);

		cursor.x = FlxG.mouse.x - cursor.frameWidth / 2;
		cursor.y = FlxG.mouse.y - cursor.frameHeight / 2 + 10;

		if (FlxG.keys.justPressed.R) {
			FlxG.resetState();
		}
		if (FlxG.keys.justPressed.SPACE) {
			skipIntro();
		}
		#if debug
		if (FlxG.keys.justPressed.D) {
			player.kill();
		}
		#end
	}

	function onBulletHit(bullet:Bullet, object:ITeam) {
		if (bullet.team != object.team) {
			var object:FlxSprite = cast object;
			object.hurt(bullet.damage);
		}
	}

	function skipIntro() {
		ui.skipIntro();
		player.startFiring();
		enemies.startSpawning();
	}
}
