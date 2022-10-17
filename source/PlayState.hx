import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxShaderMaskCamera;
import flixel.math.FlxPoint;
import flixel.system.frontEnds.CameraFrontEnd;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.display.Shader;
import openfl.filters.ShaderFilter;
import openfl.geom.Point;
import openfl.geom.Rectangle;

class PlayState extends LightingState {
	public var lightPoint = FlxPoint.get(0.5, 0.5);

	function getRandomPath(length:Int):Array<FlxPoint> {
		var path = [
			for (i in 0...length) {
				FlxPoint.get(FlxG.random.float(FlxG.width), FlxG.random.float(FlxG.height));
			}
		];
		return path;
	}

	function makeDiamond() {
		var path = getRandomPath(10);

		var baseSprite = new LightSprite(AssetPaths.diamond__png, true, 32, 32);
		baseSprite.pixelPerfectRender = true;
		baseSprite.normal.pixelPerfectRender = true;
		baseSprite.animation.add("spin", [0, 1, 2, 3], 5);
		baseSprite.animation.play("spin");
		baseSprite.setPosition(path[0].x, path[0].y);
		add(baseSprite);
		FlxTween.linearPath(baseSprite, path, 30, {type: PINGPONG});
	}

	function makeCircle() {
		var path = getRandomPath(10);

		var baseSprite = new LightSprite(AssetPaths.circle__png);
		baseSprite.pixelPerfectRender = true;
		baseSprite.normal.pixelPerfectRender = true;
		baseSprite.setPosition(path[0].x, path[0].y);
		add(baseSprite);
		FlxTween.linearPath(baseSprite, path, 30, {type: PINGPONG});
	}

	function makeUnshadedSprite() {
		var path = getRandomPath(10);

		var sprite = new FlxSprite();
		sprite.pixelPerfectRender = true;
		sprite.makeGraphic(32, 32, FlxColor.GRAY);
		add(sprite);
		FlxTween.linearPath(sprite, path, 30, {type: PINGPONG});
	}

	override public function create():Void {
		super.create();

		for (i in 0...10) {
			makeDiamond();
		}

		for (i in 0...10) {
			makeCircle();
		}

		for (i in 0...10) {
			makeUnshadedSprite();
		}
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		lightShader.setLightPositions([lightPoint]);

		if (FlxG.keys.justPressed.SPACE) {
			toggleLightingDebugCamera();
		}
	}
}
