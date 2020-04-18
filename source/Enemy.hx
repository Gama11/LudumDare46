enum EnemyType {
	Basic(xDir:Int);
}

class Enemy extends FlxSprite implements ITeam {
	public var team(default, null):Team = Enemy;

	final fireTimer = new FlxTimer();
	final bullets:Bullets;
	var type:EnemyType;

	public function new(bullets) {
		super();
		this.bullets = bullets;
		makeGraphic(60, 60, FlxColor.RED);
		health = 10;
	}

	public function init(x, y, type) {
		reset(x, y);
		this.type = type;
		velocity.y = 150;
		health = 5;
		fireTimer.cancel();
		fireTimer.start(1, _ -> shoot(), 0);

		switch type {
			case Basic(xDir):
				velocity.x = 50 * xDir;
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (y > 1000) {
			kill();
		}
	}

	function shoot() {
		var angleOffset = 180;
		var deltaAngle = 20;
		var y = y + frameHeight - 2;
		var x = x + frameWidth / 2;

		var fire = bullets.spawn.bind(x, y, Enemy, FlxColor.RED, _, Normal, 300);
		fire(angleOffset - deltaAngle);
		fire(angleOffset);
		fire(angleOffset + deltaAngle);
	}

	override function kill() {
		super.kill();
		fireTimer.cancel();
	}
}
