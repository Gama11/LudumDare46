class Enemies extends FlxTypedGroup<Enemy> {
	static final TimeBetweenWaves = 2;

	final bullets:Bullets;
	var dir = -1;
	var waveType = BulletWall;
	var wavesSpawned = 0;
	var spawnTimer = new FlxTimer();

	var holeOffset = 0;
	var holeWidth = 0;
	var holeWavesLeft = 0;

	var waveDuration:Int;

	public function new(bullets:Bullets) {
		super();
		this.bullets = bullets;
		setWaveType(waveType);
		spawnTimer.active = false;
	}

	public function spawn(x, y, type) {
		return recycle(Enemy, Enemy.new.bind(bullets)).init(x, y, type);
	}

	public function startSpawning() {
		spawnTimer.active = true;
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
		}

		wavesSpawned++;
		if (spawnTimer.elapsedLoops * spawnTimer.time > waveDuration) {
			wavesSpawned = 0;
			var choices = WaveType.createAll();
			choices.remove(waveType);
			setWaveType(FlxG.random.getObject(choices));
		}
	}

	function setWaveType(waveType:WaveType) {
		this.waveType = waveType;
		spawnTimer.cancel();
		new FlxTimer().start(TimeBetweenWaves, function(_) {
			spawnTimer.start(switch waveType {
				case Enemies: 3;
				case BulletWall: 0.3;
			}, _ -> spawnWave(), 0);
		});
		waveDuration = FlxG.random.int(5, 10);
	}
}

enum WaveType {
	Enemies;
	BulletWall;
}
