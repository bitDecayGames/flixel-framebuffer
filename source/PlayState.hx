import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxShaderMaskCamera;
import flixel.math.FlxMath;
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
	public var lightPoint = FlxPoint.get(0.4, 0.2);
	public var lightPoint2 = FlxPoint.get(0.2, 0.8);

	public var lightHeight = 0.05;
	public var lightHeight2 = 1.0;

	override public function create():Void {
		super.create();

		for (i in 0...5) {
			makeUnshadedSprite();
		}

		for (i in 0...10) {
			makeDiamond();
		}

		for (i in 0...10) {
			makeCircle();
		}

		FlxG.watch.add(this, "lightHeight", "Light1 Height:");
		FlxG.watch.add(this, "lightHeight2", "Light2 Height:");

		lightShader.lightColor1.value = [0.0, 4.0, 4.0];
		lightShader.lightColor2.value = [10.0, 1.0, 0.0];
		lightShader.lightColor3.value = [1.0, 0.0, 0.0];

		lightShader.ambientColor.value = [1.0, 1.0, 1.0];
		lightShader.ambientStrength.value = [0.2];

		lightShader.debugLights.value = [true];
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		// lightShader.setLightPositions([lightPoint, lightPoint2], [lightHeight, lightHeight2]);
		lightShader.setLightPositions([lightPoint], [lightHeight]);

		if (FlxG.keys.justPressed.SPACE) {
			toggleLightingDebugCamera();
		}

		if (FlxG.mouse.pressed) {
			lightPoint.set(FlxG.mouse.getScreenPosition().x, FlxG.mouse.getScreenPosition().y);
			lightPoint.x /= FlxG.width;
			lightPoint.y /= FlxG.height;

			if (FlxG.mouse.wheel > 0) {
				lightHeight = FlxMath.bound(lightHeight + 0.1, 0.01, 1);
			} else if (FlxG.mouse.wheel < 0) {
				lightHeight = FlxMath.bound(lightHeight - 0.1, 0.01, 1);
			}
		}

		if (FlxG.mouse.pressedRight) {
			lightPoint2.set(FlxG.mouse.getScreenPosition().x, FlxG.mouse.getScreenPosition().y);
			lightPoint2.x /= FlxG.width;
			lightPoint2.y /= FlxG.height;

			if (FlxG.mouse.wheel > 0) {
				lightHeight2 = FlxMath.bound(lightHeight2 + 0.1, 0.01, 1);
			} else if (FlxG.mouse.wheel < 0) {
				lightHeight2 = FlxMath.bound(lightHeight2 - 0.1, 0.01, 1);
			}
		}
	}

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
		baseSprite.normalMap.pixelPerfectRender = true;
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
		baseSprite.normalMap.pixelPerfectRender = true;
		baseSprite.setPosition(path[0].x, path[0].y);
		add(baseSprite);
		FlxTween.linearPath(baseSprite, path, 30, {type: PINGPONG});
	}

	function makeUnshadedSprite() {
		var path = getRandomPath(10);

		var sprite = new FlxSprite();
		sprite.pixelPerfectRender = true;
		sprite.setPosition(path[0].x, path[0].y);
		sprite.makeGraphic(32, 32, FlxColor.GRAY);
		add(sprite);
		FlxTween.linearPath(sprite, path, 30, {type: PINGPONG});
	}
}
