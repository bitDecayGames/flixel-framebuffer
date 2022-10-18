import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxShader;
import openfl.display.BitmapData;

class LightingShader extends FlxShader {
	@:glFragmentSource('
		#pragma header
		uniform sampler2D normalTex;
		uniform sampler2D heightTex;

		uniform float numLights;

		uniform vec3 lightPos1;
		uniform vec3 lightPos2;
		uniform vec3 lightPos3;

		// Note that light color values can exceed 1.0 for any channel
		// to achieve the desired brightness
		uniform vec3 lightColor1;
		uniform vec3 lightColor2;
		uniform vec3 lightColor3;

		uniform vec3 ambientColor;
		uniform float ambientStrength;

		uniform bool debugLights;

		// This value dictates how quickly distance affects light brightness.
		// A higher value means brightness dies quicker. Typicaly values [1, 2]
		// TODO: Do we want this to be a property of each individual light, or
		//       a global setting like it is now?
		uniform float lightFadeFactor;

		uniform float aspectRatio;

		vec4 getLight(vec3 lPos, vec3 color) {
			// pull out the color vectors from the source image and the normal image
			vec4 source = flixel_texture2D(bitmap, openfl_TextureCoordv);
			vec3 normal = texture2D(normalTex, openfl_TextureCoordv).rgb;
			// the image is black and white (using all 3 rbg channels), but we can just take one of them
			float fragHeight = texture2D(heightTex, openfl_TextureCoordv).z;

			if (length(normal) == 0.) {
				// No normal data, assume flat surface with normal pointing directly at camera
				normal = vec3(0.5, 0.5, 1.0);
			}

			// this is the vector from our fragment to our light position
			vec3 fragToLight = lPos - vec3(openfl_TextureCoordv, fragHeight);

			// adjust for aspect ratio
			fragToLight.xy /= vec2(1, aspectRatio);

			// invert the y value since uv coords have reversed coordinate system
			fragToLight.y *= -1.0;

			// the distance to the light source. Can be used to factor in lowered
			// brightness at distance
			float distance = length(fragToLight);
			float distanceMod = mix(1., lightFadeFactor, distance);

			// normalize the vector for further maths
			fragToLight = normalize(fragToLight);

			// normal values comes in as a value between 0.0 and 1.0 (color value of 0-255)
			// we want the range to be between -1.0 and 1.0
			// Solution: -> multiply by 2 to convert range to span 0.0 to 2.0
			//           -> subtract 1.0 to make it -1.0 to 1.0
			normal = normalize(normal * 2.0 - 1.0);

			// calculate what the angle is between the normal vector and vector pointing to the light source.
			// An dot product of 1.0 means the light source and the normal are parallel (light hitting head-on)
			// an dot product of 0.0 means they are perpendicular (no light actually hitting the face)
			float product = max(dot(normal, fragToLight), 0.0);

			// compute the diffuse portion of our illumination
			vec3 diffuse = color * product / pow(distanceMod, 2.);

			// This assumes an orthographic viewpoint
			vec3 camDir = vec3(0.0, 0.0, 1.0);

			// The angle the light would reflect off of the surface
			vec3 reflectDir = reflect(-fragToLight, normal);

			// TODO: This should be contained somewhere else
			// modifier for overall strength of specular reflections
			float specularStrength = 0.5;

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
				litColor = max(litColor, getLight(lightPos1, lightColor1));
			}
			if (numLights > 1.0) {
				litColor = max(litColor, getLight(lightPos2, lightColor2));
			}
			if (numLights > 2.0) {
				litColor = max(litColor, getLight(lightPos3, lightColor3));
			}

			vec4 source = flixel_texture2D(bitmap, openfl_TextureCoordv);

			vec3 ambient = (ambientColor * ambientStrength) * source.rgb;

			vec3 resultColor = (ambient + litColor.rgb) * source.rgb;

			gl_FragColor = vec4(resultColor, source.a);

			// DEBUG for knowing where our light is
			if (debugLights) {
				float maxLightSize = 0.03;
				vec2 distance = lightPos1.xy - openfl_TextureCoordv;
				distance /= vec2(1, aspectRatio);
				if (length(distance) < .01 + maxLightSize * lightPos1.z) {
					gl_FragColor = vec4(normalize(lightColor1), 1.);
				}

				distance = lightPos2.xy - openfl_TextureCoordv;
				distance /= vec2(1, aspectRatio);
				if (length(distance) < .01 + maxLightSize * lightPos2.z) {
					gl_FragColor = vec4(normalize(lightColor2), 1.);
				}

				distance = lightPos3.xy - openfl_TextureCoordv;
				distance /= vec2(1, aspectRatio);
				if (length(distance) < .01 + maxLightSize * lightPos3.z) {
					gl_FragColor = vec4(normalize(lightColor3), 1.);
				}
			}
			// END DEBUG
		}')
	public function new(normalPixels:BitmapData, heightPixels:BitmapData) {
		super();
		normalTex.input = normalPixels;
		heightTex.input = heightPixels;

		lightFadeFactor.value = [2.5];

		var ratio = 1.0 * FlxG.width / FlxG.height;
		aspectRatio.value = [ratio];
	}

	// for this to work properly, you will need to convert your light position into local coordinates for the camera in terms from 0.0-1.0
	public function setLightPositions(positions:Array<FlxPoint>, heights:Array<Float>) {
		if (positions.length > 0) {
			lightPos1.value = [positions[0].x, positions[0].y, heights[0]];
		}
		if (positions.length > 1) {
			lightPos2.value = [positions[1].x, positions[1].y, heights[1]];
		}
		if (positions.length > 2) {
			lightPos3.value = [positions[2].x, positions[2].y, heights[2]];
		}

		numLights.value = [Math.min(positions.length, 3)];
	}
}
