import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxState;
import flixel.system.frontEnds.CameraFrontEnd;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.filters.ShaderFilter;

// A FlxState that houses all logic needed to house LightSprite objects
// and provide the proper logic to support a camera-level dynamic lighting
// shader/filter.
class LightingState extends FlxState {
	public var lightShader:LightingShader;
	public var baseCam:FlxCamera;
	public var normalCamera:FlxCamera;

	// This acts as our frame buffer. The normalCamera's view is drawn to this
	// every frame so that it can be given to the shader
	public var normalTexture:BitmapData;

	// A private CameraFrontEnd instance to allow us to call the proper
	// functions to render our normal camera outside of the standard
	// FlxG.draw() process.
	@:access(flixel.system.frontEnds.CameraFrontEnd)
	private var normalCameraFrontEnd = new CameraFrontEnd();

	override public function create():Void {
		normalTexture = new BitmapData(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);
		normalCamera = new FlxCamera();
		normalCamera.bgColor = FlxColor.BLACK;

		// Some trickery to get our side CameraFrontEnd configured properly
		normalCameraFrontEnd.reset(normalCamera);
		FlxG.cameras.reset();
		baseCam = FlxG.camera;

		lightShader = new LightingShader(normalTexture);
		baseCam.setFilters([new ShaderFilter(lightShader)]);
	}

	// Makes sure to handle any LightSprites and set cameras properly
	override function add(Object:FlxBasic):FlxBasic {
		var ret = super.add(Object);

		if (Std.isOfType(Object, LightSprite)) {
			var lightSprite = cast(Object, LightSprite);
			super.add(lightSprite.normal);
			lightSprite.normal.cameras = [normalCamera];
		}

		return ret;
	}

	@:access(flixel.FlxCamera)
	@:access(flixel.system.frontEnds.CameraFrontEnd)
	override function draw() {
		super.draw();

		// we need to render the normal composite before the main
		// camera renders so that the shader has accurate inputs
		normalCameraFrontEnd.lock();
		// var oldCams = cameras;
		// cameras = [normalCam];
		super.draw();
		// cameras = oldCams;
		normalCamera.render();
		normalCameraFrontEnd.unlock();

		normalTexture.draw(normalCamera.canvas);
	}

	public function toggleLightingDebugCamera() {
		if (FlxG.cameras.list.contains(normalCamera)) {
			FlxG.cameras.remove(normalCamera, false);
		}
		else {
			FlxG.cameras.add(normalCamera, false);
		}
	}
}
