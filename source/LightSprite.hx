import flixel.FlxSprite;
import openfl.Assets;

// A sprite that automatically loads a corresponding *_norm.<ext> file.
// This keeps the frame index aligned to support animations seemlessly
class LightSprite extends FlxSprite {
	public var normalMap:FlxSprite;
	public var heightMap:FlxSprite;

	public function new(path:String, animated:Bool = false, width:Int = 0, height:Int = 0) {
		super();
		loadGraphic(path, animated, width, height);

		normalMap = loadCustomSprite(path, "_norm", animated, width, height);
		heightMap = loadCustomSprite(path, "_height", animated, width, height);
	}

	private function loadCustomSprite(basePath:String, suffix:String, animated:Bool, width:Int, height:Int):FlxSprite {
		var pieces = basePath.split(".");
		var customSpritePath = [pieces[0], suffix, ".", pieces[1]].join("");
		if (!Assets.exists(customSpritePath)) {
			throw 'expected to find corresponding ${customSpritePath} for ${path}, but it does not exist';
		}
		var custom = new FlxSprite();
		custom.loadGraphic(customSpritePath, animated, width, height);
		// We'll be managing the custom sprite as part of this sprite's `update(...)`
		custom.active = false;
		return custom;
	}

	// handles keeping the normal sprite in sync with this sprite.
	// Ideally everything desired to be synced would be handled here:
	// position, rotation, scale, etc.
	override function update(elapsed:Float) {
		super.update(elapsed);
		syncCustomSprite(normalMap);
		syncCustomSprite(heightMap);
	}

	private function syncCustomSprite(c:FlxSprite) {
		c.animation.frameIndex = animation.frameIndex;
		c.x = this.x;
		c.y = this.y;
	}
}
