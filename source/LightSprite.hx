import flixel.FlxSprite;

// A sprite that automatically loads a corresponding *_norm.<ext> file.
// This keeps the frame index aligned to support animations seemlessly
class LightSprite extends FlxSprite {
	public var normal:FlxSprite;

	public function new(path:String, animated:Bool = false, width:Int = 0, height:Int = 0) {
		super();
		loadGraphic(path, animated, width, height);

		var pieces = path.split(".");
		var normalSpritePath = [pieces[0], "_norm", ".", pieces[1]].join("");
		normal = new FlxSprite();
		normal.loadGraphic(normalSpritePath, animated, width, height);

		// We'll be managing this sprite
		normal.active = false;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		normal.animation.frameIndex = animation.frameIndex;
		normal.x = this.x;
		normal.y = this.y;
	}
}
