package;

import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite {
	public function new() {
		super();
		addChild(new FlxGame(0, 0, PlayState));
		FlxG.autoPause = false;
		var fps = new FPS(0, 10, 0x000000);
		addChild(fps);

		FlxG.mouse.useSystemCursor = true;
	}
}
