class Enemies extends FlxTypedGroup<Enemy> {
	static final TimeBetweenWaves = 2;

	public var boss(default, null):Enemy;

	final bullets:Bullets;
	var dir = -1;
	var wavesSpawned = 0;
	var spawnTimer = new FlxTimer();
	var waveType:WaveType;

	var holeOffset = 0;
	var holeWidth = 0;
	var holeWavesLeft = 0;

	var waveDuration:Int;

	public function new(bullets:Bullets) {
		super();
		this.bullets = bullets;
	}

	public function spawn(x, y, type) {
		var enemy = recycle(Enemy, Enemy.new.bind(bullets));
		enemy.init(x, y, type);
		return enemy;
	}

	public function startSpawning() {
		setWaveType(Enemies);
	}

	function spawnWave() {
		switch waveType {
			case Enemies:
				var xOffset = if (dir == -1) 300 else -100;
				for (i in 0...5) {
					spawn(10 + i * 100 + xOffset, -100 - i * 10, Basic(dir));
				}
				dir *= -1;

			case BulletWall:
				var margin = 30;
				if (wavesSpawned % 7 == 0) {
					holeWidth = FlxG.random.int(4, 7);
					holeOffset = Std.int(Math.max(0, FlxG.random.int(0, Std.int(FlxG.width / margin)) - holeWidth));
					holeWavesLeft = Std.int(holeWidth * 0.75);
				}

				var i = 0;
				while (margin * i < FlxG.width) {
					if (holeWavesLeft <= 0 || i < holeOffset || i > holeOffset + holeWidth) {
						bullets.spawn(margin * i, -10, Enemy, FlxColor.CYAN, 180, Normal, 200);
					}
					i++;
				}
				holeWavesLeft--;

			case Boss:
				if (boss != null) {
					return;
				}
				boss = spawn(0, 0, Boss);
				FlxG.sound.play("assets/sounds/boss_spawn.wav");
		}

		wavesSpawned++;

		if (spawnTimer.elapsedLoops * spawnTimer.time > waveDuration) {
			startNextWave();
		}
	}

	function setWaveType(waveType:WaveType) {
		this.waveType = waveType;
		spawnTimer.cancel();
		new FlxTimer().start(TimeBetweenWaves, function(_) {
			spawnTimer.start(switch waveType {
				case Enemies: 3;
				case BulletWall: 0.3;
				case Boss: 1;
			}, _ -> spawnWave(), if (waveType == Boss) 1 else 0);
			PlayState.FirstWaveBeaten = true;
		});
		waveDuration = FlxG.random.int(5, 10);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (boss != null && !boss.alive) {
			startNextWave();
		}
	}

	function startNextWave() {
		wavesSpawned = 0;
		boss = null;
		var choices = WaveType.createAll();
		choices.remove(waveType);
		setWaveType(FlxG.random.getObject(choices));
	}
}

enum WaveType {
	Enemies;
	BulletWall;
	Boss;
}
