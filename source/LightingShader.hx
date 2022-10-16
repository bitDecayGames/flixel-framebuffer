import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxShader;
import openfl.display.BitmapData;

class LightingShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		uniform sampler2D normalTex;
		uniform vec2 lightPos1;
		uniform vec2 lightPos2;
		uniform vec2 lightPos3;
		uniform vec2 lightPos4;
		uniform vec2 lightPos5;
		uniform vec2 lightPos6;
		uniform vec2 lightPos7;
		uniform vec2 lightPos8;
		uniform vec2 lightPos9;
		uniform vec2 lightPos0;
		uniform float numLights;
		uniform float lightHeight;
		uniform float ambientRatio;
		uniform float aspectRatio;

		vec4 getLight(vec2 lPos) {
			// pull out the color vectors from the source image and the normal image
			vec4 source = flixel_texture2D(bitmap, openfl_TextureCoordv);
			vec4 normal = texture2D(normalTex, openfl_TextureCoordv);

			vec2 distance = lPos - openfl_TextureCoordv;
			distance *= vec2(1, aspectRatio);

			// if (length(distance) > 1.0) {
			// 	return vec4(0., 0., 0., 0.);
			// }

            // calculate the vector going from the texture coord to the light source and add some height to this vector
			vec4 toLight = vec4(lPos - openfl_TextureCoordv, lightHeight, 0);

			// invert the y value since uv coords have reversed coordinate system
			toLight.y *= -1.0;



			// normalize the normal vector (honestly not sure why we need the *2.0-1 thing here, but it doesnt work without it)
			// ANSWER:
			// value comes in as a value between 0.0 and 1.0 (color value of 0-255)
			// we want the range to be between -1.0 and 1.0
			// Solution: -> multiply by 2 to convert range to span 0.0 to 2.0
			//           -> subtract 1.0 to make it -1.0 to 1.0
			normal = normalize(normal * 2.0 - 1.0);

			// calculate what the angle is between the normal vector and the pixel to the light source.
			// An angle of 1.0 means the light source and the normal are parallel
			// an angle of 0.0 means they are perpendicular
			float cos_angle = dot(normal, toLight);

			// distance from the light
			float dist = length(lPos - openfl_TextureCoordv);
			float distanceImpact = clamp(dist, 0.01, 1.) / 1.;
			distanceImpact = 1. - pow(distanceImpact, 5.);

			cos_angle *= distanceImpact;

			// clamp the "angle" which is now basically the intensity of the light on the pixel and
			// bring up the bottom of the clamp to match the ambientRatio which basically just makes
			// sure each pixel is drawn with at least SOME color instead of being completely black
			// (use 0.0 for ratio if you want completely black)
			cos_angle = clamp(cos_angle, ambientRatio, 1.0);

			// multiply the rgb of the source color vector by the angle/intensity to either brighten or dim the color at this pixel, and just use the original alpha from the source directly, dont manipulate that with light
			source.rgb *= cos_angle;
			source.a = 1.;

			return source;
		}

		void main()
		{
			vec4 litColor = vec4(0.,0.,0.,0.);
			if (numLights > 0.0) {
				litColor = max(litColor, getLight(lightPos0));
			}
			if (numLights > 1.0) {
				litColor = max(litColor, getLight(lightPos1));
			}
			if (numLights > 2.0) {
				litColor = max(litColor, getLight(lightPos2));
			}
			if (numLights > 3.0) {
				litColor = max(litColor, getLight(lightPos3));
			}
			if (numLights > 4.0) {
				litColor = max(litColor, getLight(lightPos4));
			}
			if (numLights > 5.0) {
				litColor = max(litColor, getLight(lightPos5));
			}
			if (numLights > 6.0) {
				litColor = max(litColor, getLight(lightPos6));
			}
			if (numLights > 7.0) {
				litColor = max(litColor, getLight(lightPos7));
			}
			if (numLights > 8.0) {
				litColor = max(litColor, getLight(lightPos8));
			}
			if (numLights > 9.0) {
				litColor = max(litColor, getLight(lightPos9));
			}

			vec4 source = flixel_texture2D(bitmap, openfl_TextureCoordv);

			if (litColor.a < 1.) {
				// counting lights on the alpha channel. 0 meansno lights lit this pixel;
				litColor.rgb = source.rgb * ambientRatio;
			}

			gl_FragColor = vec4(litColor.rgb, source.a);

			vec2 distance = lightPos0 - openfl_TextureCoordv;
			// distance *= vec2(1, aspectRatio);
			if (length(distance) < .05) {
				gl_FragColor = vec4(1., 1., 1., 1.);
			}

			// vec4 tester = flixel_texture2D(normalTex, openfl_TextureCoordv);
			// gl_FragColor = tester;
		}')
	public function new(pixels:BitmapData)
	{
		super();
		setNormalMapPixels(pixels);
		setLightPositions([new FlxPoint(0, 0)]);
		setLightHeight(1);
		setAmbientRatio(0.2);

		var ratio = 1.0 * FlxG.width / FlxG.height;
		setAspectRatio(ratio);
	}

	// this is the normal sprite that you are going to pass into the shader
	public function setNormalMapPixels(pixels:BitmapData)
	{
		normalTex.input = pixels;
	}

	// for this to work properly, you will need to convert your light position into local coordinates to the sprite, then into a ratio between 0-1 based on the sprite's total width (if it is a sprite sheet, you will need to take frameWidth * numOfFrames)
	public function setLightPositions(positions:Array<FlxPoint>)
	{
		if (positions.length > 0)
		{
			lightPos0.value = [positions[0].x, positions[0].y];
		}
		if (positions.length > 1)
		{
			lightPos1.value = [positions[1].x, positions[1].y];
		}
		if (positions.length > 2)
		{
			lightPos2.value = [positions[2].x, positions[2].y];
		}
		if (positions.length > 3)
		{
			lightPos3.value = [positions[3].x, positions[3].y];
		}
		if (positions.length > 4)
		{
			lightPos4.value = [positions[4].x, positions[4].y];
		}
		if (positions.length > 5)
		{
			lightPos5.value = [positions[5].x, positions[5].y];
		}
		if (positions.length > 6)
		{
			lightPos6.value = [positions[6].x, positions[6].y];
		}
		if (positions.length > 7)
		{
			lightPos7.value = [positions[7].x, positions[7].y];
		}
		if (positions.length > 8)
		{
			lightPos8.value = [positions[8].x, positions[8].y];
		}
		if (positions.length > 9)
		{
			lightPos9.value = [positions[9].x, positions[9].y];
		}

		numLights.value = [Math.min(positions.length, 10)];
	}

	// I'm not totally sure this is really what I'm saying it is, but theoretically this changes how high the light is in the "sky" compared to the flat sprite is on the "ground"
	public function setLightHeight(height:Float)
	{
		lightHeight.value = [height];
	}

	// setting this ratio to 1 will basically ignore the lightsource completely and just bathe everything in full light, while setting to 0 will cause the sprite to draw black if there is no light directly on it (black, not transparent)
	public function setAmbientRatio(ratio:Float)
	{
		if (ratio < 0)
			ambientRatio.value = [0.0];
		else if (ratio > 1.0)
			ambientRatio.value = [1.0];
		else
			ambientRatio.value = [ratio];
	}

	public function setAspectRatio(ratio:Float)
	{
		aspectRatio.value = [ratio];
	}
}
