import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class CoinState extends LightingState {
	public var lightPoint = FlxPoint.get(0.4, 0.2);

	public var lightHeight = 0.2;

	override public function create():Void {
		super.create();

		var baseSprite = new LightSprite(FlxG.width / 2, FlxG.height / 2, AssetPaths.coin__png, true, 32, 32);
		baseSprite.pixelPerfectRender = true;
		baseSprite.scale.set(3, 3);
		add(baseSprite);

		lightShader.lightColor1.value = [2.0, 2.0, 2.0];

		lightShader.ambientColor.value = [1.0, 1.0, 1.0];
		lightShader.ambientStrength.value = [0.2];

		lightShader.debugLights.value = [true];
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		lightShader.setLightPositions([lightPoint], [lightHeight]);

		if (FlxG.keys.justPressed.SPACE) {
			toggleLightingDebugCamera();
		}

		if (FlxG.mouse.pressed) {
			lightPoint.set(FlxG.mouse.getScreenPosition().x, FlxG.mouse.getScreenPosition().y);
			lightPoint.x /= FlxG.width;
			lightPoint.y /= FlxG.height;

			if (FlxG.mouse.wheel > 0) {
				lightHeight = FlxMath.bound(lightHeight + 0.1, -1, 1);
			} else if (FlxG.mouse.wheel < 0) {
				lightHeight = FlxMath.bound(lightHeight - 0.1, -1, 1);
			}
		}

		if (FlxG.keys.justPressed.RIGHT) {
			FlxG.switchState(new PlayState());
		}
	}
}
