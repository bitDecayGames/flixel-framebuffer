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
	public var normalCam:FlxCamera;
	public var normalTexture:BitmapData;

	// A private CameraFrontEnd instance to allow us to call the proper
	// functions to render our normal camera outside of the standard
	// FlxG.draw() process.
	@:access(flixel.system.frontEnds.CameraFrontEnd)
	private var normalCameras = new CameraFrontEnd();

	override public function create():Void {
		normalTexture = new BitmapData(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);
		// normalTexture = new FlxSprite();
		// normalTexture.makeGraphic(FlxG.width, FlxG.height);
		normalCam = new FlxCamera();
		normalCam.bgColor = FlxColor.TRANSPARENT;

		// Some trickery to get our side CameraFrontEnd configured properly
		normalCameras.reset(normalCam);
		FlxG.cameras.reset();
		baseCam = FlxG.camera;

		lightShader = new LightingShader(normalTexture);
		baseCam.setFilters([new ShaderFilter(lightShader)]);
	}

	// Makes sure to handle any normals and set cameras properly
	override function add(Object:FlxBasic):FlxBasic {
		var ret = super.add(Object);

		if (Std.isOfType(Object, LightSprite)) {
			var lightSprite = cast(Object, LightSprite);
			super.add(lightSprite.normal);
			lightSprite.normal.cameras = [normalCam];
		}

		return ret;
	}

	@:access(flixel.FlxCamera)
	@:access(flixel.system.frontEnds.CameraFrontEnd)
	override function draw() {
		super.draw();

		// we need to make sure this happens before the main camera
		// renders so that the shader has the accurate data
		normalCameras.lock();
		var oldCams = cameras;
		cameras = [normalCam];
		super.draw();
		cameras = oldCams;
		normalCam.render();
		normalCameras.unlock();

		normalTexture.draw(normalCam.canvas);
	}

	public function toggleLightingDebugCamera() {
		if (FlxG.cameras.list.contains(normalCam)) {
			FlxG.cameras.remove(normalCam, false);
		}
		else {
			FlxG.cameras.add(normalCam, false);
		}
	}
}
