import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxState;
import flixel.system.frontEnds.CameraFrontEnd;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.filters.ShaderFilter;
import openfl.geom.Rectangle;

// A FlxState that houses all logic needed to house LightSprite objects
// and provide the proper logic to support a camera-level dynamic lighting
// shader/filter.
// NOTES: This doesn't support camera zoom at this time
class LightingState extends FlxState {
	public var lightShader:LightingShader;

	public var baseCam:FlxCamera;
	public var normalCamera:FlxCamera;
	public var heightCamera:FlxCamera;

	// This acts as our frame buffer. The normalCamera's view is drawn to this
	// every frame so that it can be given to the shader
	public var normalTexture:BitmapData;

	// This acts as our frame buffer. The heightCamera's view is drawn to this
	// every frame so that it can be given to the shader
	public var heightTexture:BitmapData;

	// A private CameraFrontEnd instance to allow us to call the proper
	// functions to render our normal camera outside of the standard
	// FlxG.draw() process.
	@:access(flixel.system.frontEnds.CameraFrontEnd)
	private var bufferCameraFrontEnd = new CameraFrontEnd();

	override public function create():Void {
		normalTexture = new BitmapData(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);
		normalCamera = new FlxCamera();
		normalCamera.bgColor = FlxColor.TRANSPARENT;

		heightTexture = new BitmapData(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);
		heightCamera = new FlxCamera();
		heightCamera.bgColor = FlxColor.TRANSPARENT;

		// Some trickery to get our side CameraFrontEnd configured properly
		bufferCameraFrontEnd.reset(normalCamera);
		bufferCameraFrontEnd.add(heightCamera);
		FlxG.cameras.reset();
		baseCam = FlxG.camera;

		lightShader = new LightingShader(normalTexture, heightTexture);
		baseCam.setFilters([new ShaderFilter(lightShader)]);

		// Register so we can update our cameras once the main game camera has updated
		FlxG.signals.postUpdate.add(() -> {
			for (camera in bufferCameraFrontEnd.list) {
				syncCamera(camera);
			}
		});
	}

	// Makes sure to handle any LightSprites and set cameras properly
	override function add(Object:FlxBasic):FlxBasic {
		var ret = super.add(Object);

		if (Std.isOfType(Object, LightSprite)) {
			var lightSprite = cast(Object, LightSprite);
			super.add(lightSprite.normalMap);
			super.add(lightSprite.heightMap);
			lightSprite.normalMap.cameras = [normalCamera];
			lightSprite.heightMap.cameras = [heightCamera];
		}

		return ret;
	}

	// Sync camera properties so the frame buffers align
	private function syncCamera(bufferCam:FlxCamera) {
		bufferCam.x = baseCam.x;
		bufferCam.y = baseCam.y;
		bufferCam.scroll.copyFrom(baseCam.scroll);
		bufferCam.update(FlxG.elapsed);
	}

	@:access(flixel.FlxCamera)
	@:access(flixel.system.frontEnds.CameraFrontEnd)
	override function draw() {
		super.draw();

		// we need to render the composites before the main FlxGame
		// camera renders so that the shader has accurate inputs
		bufferCameraFrontEnd.lock();
		super.draw();
		normalCamera.render();
		heightCamera.render();
		bufferCameraFrontEnd.unlock();

		// capture our camera views to textures
		normalTexture.fillRect(new Rectangle(0, 0, FlxG.width, FlxG.height), 0x00000000);
		normalTexture.draw(normalCamera.canvas);
		heightTexture.fillRect(new Rectangle(0, 0, FlxG.width, FlxG.height), 0x00000000);
		heightTexture.draw(heightCamera.canvas);
	}

	// allows us to cycle through the cameras
	public function toggleLightingDebugCamera() {
		if (FlxG.cameras.list.contains(normalCamera)) {
			FlxG.cameras.remove(normalCamera, false);
			FlxG.cameras.add(heightCamera, false);
		} else if (FlxG.cameras.list.contains(heightCamera)) {
			FlxG.cameras.remove(heightCamera, false);
		} else {
			FlxG.cameras.add(normalCamera, false);
		}
	}
}
