import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class HeightState extends LightingState {
	public var lightPoint = FlxPoint.get(0.4, 0.2);
	public var lightPoint2 = FlxPoint.get(0.2, 0.8);

	public var lightHeight = 0.05;
	public var lightHeight2 = 1.0;

	override public function create():Void {
		super.create();

		// We need something to cast shadows upon
		var bg = new FlxSprite();
		bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		add(bg);

		makeOctahedron();

		FlxG.watch.add(this, "lightHeight", "Light1 Height:");
		FlxG.watch.add(this, "lightHeight2", "Light2 Height:");

		lightShader.lightColor1.value = [0.0, 4.0, 4.0];
		lightShader.lightColor2.value = [10.0, 1.0, 0.0];

		lightShader.ambientColor.value = [1.0, 1.0, 1.0];
		lightShader.ambientStrength.value = [0.2];

		lightShader.debugLights.value = [true];
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		lightShader.setLightPositions([lightPoint, lightPoint2], [lightHeight, lightHeight2]);

		if (FlxG.keys.justPressed.SPACE) {
			toggleLightingDebugCamera();
		}

		if (FlxG.mouse.pressed) {
			lightPoint.set(FlxG.mouse.getScreenPosition().x, FlxG.mouse.getScreenPosition().y);
			lightPoint.x /= FlxG.width;
			lightPoint.y /= FlxG.height;

			if (FlxG.mouse.wheel > 0) {
				lightHeight = FlxMath.bound(lightHeight + 0.1, 0.01, 2);
			} else if (FlxG.mouse.wheel < 0) {
				lightHeight = FlxMath.bound(lightHeight - 0.1, 0.01, 2);
			}
		}

		if (FlxG.mouse.pressedRight) {
			lightPoint2.set(FlxG.mouse.getScreenPosition().x, FlxG.mouse.getScreenPosition().y);
			lightPoint2.x /= FlxG.width;
			lightPoint2.y /= FlxG.height;

			if (FlxG.mouse.wheel > 0) {
				lightHeight2 = FlxMath.bound(lightHeight2 + 0.1, 0.01, 2);
			} else if (FlxG.mouse.wheel < 0) {
				lightHeight2 = FlxMath.bound(lightHeight2 - 0.1, 0.01, 2);
			}
		}

		if (FlxG.keys.justPressed.RIGHT) {
			FlxG.switchState(new PlayState());
		}
	}

	function makeOctahedron() {
		var baseSprite = new LightSprite(AssetPaths.diamond__png, true, 32, 32);
		baseSprite.screenCenter();
		baseSprite.pixelPerfectRender = true;
		baseSprite.animation.add("spin", [0, 1, 2, 3], 5);
		baseSprite.animation.play("spin");
		add(baseSprite);
	}
}
