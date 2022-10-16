// HaxeFlixel imports
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
import flixelighting.FlxLight;
import flixelighting.FlxLighting;
import flixelighting.FlxNormalMap;
import openfl.display.BitmapData;
import openfl.display.Shader;
import openfl.filters.ShaderFilter;
import openfl.geom.Point;
import openfl.geom.Rectangle;

class PlayState extends LightingState {
	public var lightPoint = FlxPoint.get(0.5, 0.5);

	function makeDiamond() {
		var path = [
			for (i in 0...10) {
				FlxPoint.get(FlxG.random.float(FlxG.width), FlxG.random.float(FlxG.height));
			}
		];

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
		var path = [
			for (i in 0...10) {
				FlxPoint.get(FlxG.random.float(FlxG.width), FlxG.random.float(FlxG.height));
			}
		];

		var baseSprite = new LightSprite(AssetPaths.circle__png);
		baseSprite.pixelPerfectRender = true;
		baseSprite.normal.pixelPerfectRender = true;
		baseSprite.setPosition(path[0].x, path[0].y);
		add(baseSprite);
		FlxTween.linearPath(baseSprite, path, 30, {type: PINGPONG});
	}

	override public function create():Void {
		super.create();

		for (i in 0...10) {
			makeDiamond();
		}

		for (i in 0...10) {
			makeCircle();
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
