import openfl.display.Sprite;

class Main extends Sprite {
	public function new() {
		super();
		addChild(new FlxGame(0, 0, #if html5 MenuState #else PlayState #end, 1, 60, 60, true));
		FlxG.stage.showDefaultContextMenu = false;
	}
}
