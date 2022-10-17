import flixel.FlxSprite;
import openfl.Assets;

// A sprite that automatically loads a corresponding *_norm.<ext> file.
// This keeps the frame index aligned to support animations seemlessly
class LightSprite extends FlxSprite {
	public var normal:FlxSprite;

	public function new(path:String, animated:Bool = false, width:Int = 0, height:Int = 0) {
		super();
		loadGraphic(path, animated, width, height);

		var pieces = path.split(".");
		var normalSpritePath = [pieces[0], "_norm", ".", pieces[1]].join("");
		if (!Assets.exists(normalSpritePath)) {
			throw 'expected to find corresponding ${normalSpritePath} for ${path}, but it does not exist';
		}
		normal = new FlxSprite();
		normal.loadGraphic(normalSpritePath, animated, width, height);

		// We'll be managing the normal sprite as part of this sprite's `update(...)`
		normal.active = false;
	}

	// handles keeping the normal sprite in sync with this sprite.
	// Ideally everything desired to be synced would be handled here:
	// position, rotation, scale, etc.
	override function update(elapsed:Float) {
		super.update(elapsed);
		normal.animation.frameIndex = animation.frameIndex;
		normal.x = this.x;
		normal.y = this.y;
	}
}
