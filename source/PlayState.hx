import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class PlayState extends LightingState {
	public var lightPoint = FlxPoint.get(0.4, 0.2);
	public var lightPoint2 = FlxPoint.get(0.2, 1.3);

	public var lightHeight = 0.25;
	public var lightHeight2 = 2.0;

	public var objectCount = 0;
	public var objectLabel = new FlxText(0, 0);

	// We'll use a secondary camera for things we do not want the shaders
	// to affect.
	public var uiCam:FlxCamera;

	override public function create():Void {
		super.create();

		uiCam = new FlxCamera();
		uiCam.bgColor = FlxColor.TRANSPARENT;

		// if we make this a default draw target, it messes up the shader output.
		// Still need to dig into why
		FlxG.cameras.add(uiCam, false);

		objectLabel.color = FlxColor.BLACK;
		objectLabel.cameras = [uiCam];
		add(objectLabel);

		var bg = new FlxSprite();
		bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		add(bg);

		makeObjects();

		FlxG.watch.add(this, "lightHeight", "Light1 Height:");
		FlxG.watch.add(this, "lightHeight2", "Light2 Height:");

		lightShader.lightColor1.value = [0.0, 4.0, 4.0];
		lightShader.lightColor2.value = [6.0, 3.0, 0.0];

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

		if (FlxG.keys.justPressed.SHIFT) {
			camera.shake();
		}

		if (FlxG.keys.justPressed.M) {
			makeObjects();
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

		objectLabel.text = 'Objects (\'M\' to add more): $objectCount';

		if (FlxG.keys.justPressed.RIGHT) {
			FlxG.switchState(new CoinState());
		}
	}

	private function makeObjects(perEach:Int = 3) {
		for (i in 0...perEach) {
			makeUnshadedSprite();
		}

		for (i in 0...perEach) {
			makeOctahedron();
		}

		for (i in 0...perEach) {
			makeCircle();
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

	function makeOctahedron() {
		var path = getRandomPath(10);

		var baseSprite = new LightSprite(path[0].x, path[0].y, AssetPaths.diamond__png, true, 32, 32);
		baseSprite.pixelPerfectRender = true;
		baseSprite.animation.add("spin", [0, 1, 2, 3], 5);
		baseSprite.animation.play("spin");
		add(baseSprite);
		FlxTween.linearPath(baseSprite, path, 30, {type: PINGPONG});
		objectCount++;
	}

	function makeCircle() {
		var path = getRandomPath(10);

		var baseSprite = new LightSprite(path[0].x, path[0].y, AssetPaths.circle__png);
		baseSprite.pixelPerfectRender = true;
		add(baseSprite);
		FlxTween.linearPath(baseSprite, path, 30, {type: PINGPONG});
		objectCount++;
	}

	function makeUnshadedSprite() {
		var path = getRandomPath(10);

		var sprite = new FlxSprite(path[0].x, path[0].y);
		sprite.pixelPerfectRender = true;
		sprite.makeGraphic(32, 32, FlxColor.GRAY);
		add(sprite);
		FlxTween.linearPath(sprite, path, 30, {type: PINGPONG});
		objectCount++;
	}
}
