import flixel.ui.FlxButton;

class MenuState extends FlxState {
	override function create() {
		super.create();

		var button = new FlxButton("Play", () -> FlxG.switchState(new PlayState()));
		button.screenCenter();
		add(button);
	}
}
