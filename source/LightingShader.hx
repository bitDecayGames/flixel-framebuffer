import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxShader;
import openfl.display.BitmapData;

class LightingShader extends FlxShader {
	@:glFragmentSource('
		#pragma header
		uniform sampler2D normalTex;

		uniform float numLights;

		uniform vec2 lightPos1;
		uniform vec2 lightPos2;
		uniform vec2 lightPos3;
		uniform vec3 lightColor1;
		uniform vec3 lightColor2;
		uniform vec3 lightColor3;
		uniform float lightHeight1;
		uniform float lightHeight2;
		uniform float lightHeight3;

		uniform vec3 ambientColor;
		uniform float ambientStrength;

		uniform float aspectRatio;

		vec4 getLight(vec2 lPos, float lightHeight, vec3 color) {
			// pull out the color vectors from the source image and the normal image
			vec4 source = flixel_texture2D(bitmap, openfl_TextureCoordv);
			vec3 normal = texture2D(normalTex, openfl_TextureCoordv).xyz;

			// Can remove this if-block to have sprites without normal data
			// be considered as though no light is hitting them
			if (length(normal.rgb) == 0.) {
				// No normal data, so just use the input here?
				return source;
			}

			vec2 distanceVec = lPos - openfl_TextureCoordv;
			distanceVec /= vec2(1, aspectRatio);
			float distance = length(distanceVec);

            // calculate the vector going from the texture coord to the light source and add some height to this vector
			vec3 toLight = normalize(vec3(distanceVec, lightHeight));

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
			float product = max(dot(normal, toLight), 0.0);
			vec3 diffuse = color * product;

			// TODO: This should be contained somewhere else
			// modifier for overall strength of specular reflections
			float specularStrength = 0.5;

			// This assumes an orthographic viewpoint
			vec3 camDir = vec3(0.0, 0.0, 1.0);
			// The angle the light would reflect off of the surface
			vec3 reflectDir = reflect(-toLight, normal);
			// calculate the reflection against where the camera is
			float spec = pow(max(dot(camDir, reflectDir.xyz), 0.0), 32.);
			// final weight of specular reflection taking light color into account
			vec3 specular = specularStrength * spec * color;

			// multiply the rgb of the source color vector by the angle/intensity to either brighten or dim the color at this pixel, and just use the original alpha from the source directly, dont manipulate that with light
			source.rgb *= (diffuse + specular);

			return source;
		}

		void main()
		{
			vec4 litColor = vec4(0.,0.,0.,0.);
			if (numLights > 0.0) {
				litColor = max(litColor, getLight(lightPos1, lightHeight1, lightColor1));
			}
			if (numLights > 1.0) {
				litColor = max(litColor, getLight(lightPos2, lightHeight2, lightColor2));
			}
			if (numLights > 2.0) {
				litColor = max(litColor, getLight(lightPos3, lightHeight3, lightColor3));
			}

			vec4 source = flixel_texture2D(bitmap, openfl_TextureCoordv);

			vec3 ambient = (ambientColor * ambientStrength) * source.rgb;

			vec3 resultColor = (ambient + litColor.rgb) * source.rgb;

			gl_FragColor = vec4(resultColor, source.a);

			// DEBUG for knowing where our light is
			float maxLightSize = 0.03;
			vec2 distance = lightPos1 - openfl_TextureCoordv;
			distance /= vec2(1, aspectRatio);
			if (length(distance) < .01 + maxLightSize * lightHeight1) {
				gl_FragColor = vec4(lightColor1, 1.);
			}

			distance = lightPos2 - openfl_TextureCoordv;
			distance /= vec2(1, aspectRatio);
			if (length(distance) < .01 + maxLightSize * lightHeight2) {
				gl_FragColor = vec4(lightColor2, 1.);
			}

			distance = lightPos3 - openfl_TextureCoordv;
			distance /= vec2(1, aspectRatio);
			if (length(distance) < .01 + maxLightSize * lightHeight3) {
				gl_FragColor = vec4(lightColor3, 1.);
			}
			// END DEBUG
		}')
	public function new(pixels:BitmapData) {
		super();
		setNormalMapPixels(pixels);

		var ratio = 1.0 * FlxG.width / FlxG.height;
		setAspectRatio(ratio);
	}

	// this is the normal sprite that you are going to pass into the shader
	public function setNormalMapPixels(pixels:BitmapData) {
		normalTex.input = pixels;
	}

	// for this to work properly, you will need to convert your light position into local coordinates for the camera in terms from 0.0-1.0
	public function setLightPositions(positions:Array<FlxPoint>) {
		if (positions.length > 0) {
			lightPos1.value = [positions[0].x, positions[0].y];
		}
		if (positions.length > 1) {
			lightPos2.value = [positions[1].x, positions[1].y];
		}
		if (positions.length > 2) {
			lightPos3.value = [positions[2].x, positions[2].y];
		}

		numLights.value = [Math.min(positions.length, 3)];
	}

	// how much z the lights have
	public function setLightHeights(heights:Array<Float>) {
		if (heights.length > 0) {
			lightHeight1.value = [heights[0]];
		}
		if (heights.length > 1) {
			lightHeight2.value = [heights[1]];
		}
		if (heights.length > 2) {
			lightHeight3.value = [heights[2]];
		}
	}

	public function setAspectRatio(ratio:Float) {
		aspectRatio.value = [ratio];
	}
}
