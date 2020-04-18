enum EnemyType {
	Basic(xDir:Int);
}

class Enemy extends FlxSprite implements ITeam {
	static final FireRate = 0.2;

	public var team(default, null):Team = Enemy;

	final fireTimer = new FlxTimer();
	final bullets:Bullets;
	var type:EnemyType;
	var waitUntilNextVolley:Int = 0;
	var shot:Int = 0;
	var maxHealth:Int;

	public function new(bullets) {
		super();
		this.bullets = bullets;
		makeGraphic(30, 30, FlxColor.GREEN);
	}

	public function init(x, y, type) {
		reset(x, y);
		this.type = type;
		velocity.y = 150;
		health = 5;
		fireTimer.cancel();
		fireTimer.start(FireRate, _ -> shoot(), 0);
		health = maxHealth = 10;

		switch type {
			case Basic(xDir):
				velocity.x = 50 * xDir;
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (y > 1000) {
			exists = false;
		}
	}

	function shoot() {
		if (waitUntilNextVolley > 0) {
			waitUntilNextVolley--;
			return;
		}

		var angleOffset = 180;
		var deltaAngle = 20;
		var y = y + frameHeight - 2;
		var x = x + frameWidth / 2;

		var fire = bullets.spawn.bind(x, y, Enemy, FlxColor.RED, _, Normal, 300);
		fire(angleOffset - deltaAngle);
		fire(angleOffset);
		fire(angleOffset + deltaAngle);

		shot++;
		if (shot > 5) {
			waitUntilNextVolley = 6;
			shot = 0;
		}
	}

	override function kill() {
		super.kill();
		fireTimer.cancel();
		FlxG.sound.play("assets/sounds/explode_enemy.wav");
	}

	override function hurt(damage:Float) {
		super.hurt(damage);
		alpha = Math.max(health / maxHealth, 0.2);
	}
}
