import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
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

		uniform float shadowStep;

		uniform bool debugLights;

		// This value dictates how quickly distance affects light brightness.
		// A higher value means brightness dies quicker. Typicaly values [1, 2]
		// TODO: Do we want this to be a property of each individual light, or
		//       a global setting like it is now?
		uniform float lightFadeFactor;

		uniform float aspectRatio;
		uniform vec2 resolution;

		bool isInShadow(vec3 fragPosition, vec3 toLight, float maxDistance) {
			toLight.y *= -1.0;

			float distance = 0.;
			for (int i = 1; i < 1000; i++) {
				distance = shadowStep * 2.0 * float(i);
				if (distance >= maxDistance) {
					return false;
				}

				vec3 raySampleCoords = fragPosition + (toLight * distance) / vec3(aspectRatio, 1., 1.);
				vec4 heightSample = texture2D(heightTex, raySampleCoords.xy);

				if (heightSample.r > raySampleCoords.z && raySampleCoords.z > heightSample.g) {
					// the light ray hits within our height range, so the pixel blocks the light
					return true;
				}
			}

			return false;
		}

		vec4 getIllumination(vec3 lPos, vec3 color) {
			// pull out the color vectors from the source image and the normal image
			vec4 source = flixel_texture2D(bitmap, openfl_TextureCoordv);
			vec3 normal = texture2D(normalTex, openfl_TextureCoordv).rgb;
			// The height data is currently represented by two numbers:
			//    green: represents the minimum height for the pixel
			//    red: represents the maximum height for the pixel
			vec4 fragHeightData = texture2D(heightTex, openfl_TextureCoordv);

			if (length(normal) == 0.) {
				// No normal data, assume flat surface with normal pointing directly at camera
				normal = vec3(0.5, 0.5, 1.0);
			}

			// The red channel contains our "max" height for the frag, so that is our reference point for the frag
			vec3 fragPosition = vec3(openfl_TextureCoordv, fragHeightData.r);

			// TODO: we want each pixel to gauge height information based on the center of the nearest pixel. This
			// should clean up the little height artifacts significantly

			// this is the vector from our fragment to our light position
			vec3 fragToLight = lPos - fragPosition;

			// adjust for aspect ratio to get our vector "circular"
			fragToLight.xy /= vec2(1., aspectRatio);

			// invert the y value since uv coords have reversed coordinate system
			fragToLight.y *= -1.0;

			// the distance to the light source. Can be used to factor in lowered
			// brightness at distance
			float distance = length(fragToLight);
			float distanceMod = mix(1., lightFadeFactor, distance);

			// normalize the vector for further maths
			fragToLight = normalize(fragToLight);

			// TODO: Here we do a shadow check to see if this light is actually illuminating this pixel
			bool shaded = isInShadow(fragPosition, fragToLight, distance);
			if (shaded) {
				source.rgb = vec3(0.);
				return source;
			}

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
				litColor = max(litColor, getIllumination(lightPos1, lightColor1));
			}
			if (numLights > 1.0) {
				litColor = max(litColor, getIllumination(lightPos2, lightColor2));
			}
			if (numLights > 2.0) {
				litColor = max(litColor, getIllumination(lightPos3, lightColor3));
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
		trace(ratio);

		var pixelRes = FlxVector.get(1.0 / FlxG.width, 1.0 / FlxG.height);
		resolution.value = [pixelRes.x, pixelRes.y];

		// steps should be one pixel at a time
		shadowStep.value = [1.0 / FlxG.width];
		trace(shadowStep.value);
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
