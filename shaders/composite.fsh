#version 330 compatibility

#include "/lib/distort.glsl"

#include "/lib/colors.glsl"

const float shadowDistanceRenderMul = 1.0;
const int noiseTextureResolution = 64;

uniform sampler2D depthtex0;

// can access colortex 0 to 15. https://shaders.properties/current/reference/buffers/colortex/
uniform sampler2D colortex0;
uniform sampler2D colortex1;  // lightmap
uniform sampler2D colortex2;  // encodedNormals
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;

uniform sampler2D noisetex;

uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

uniform vec3 shadowLightPosition;  // gives sun/moon pos
uniform float viewHeight;
uniform float viewWidth;
uniform float sunAngle;

in vec2 texcoord;

/*
const int colortex0Format = RGB16;
*/


// tells iris patcher to write back to colortex0
/* RENDERTARGETS: 0 */
// "color" will be written to colortex0.
layout(location = 0) out vec4 color;


vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
	vec4 homPos = projectionMatrix * vec4(position, 1.0);
	return homPos.xyz / homPos.w;
}


float calc_grayscale(vec4 color) {
	// grayscale is done by taking dot product of a color and vec3(1.0/3.0), then taking avg of products
	// then you just set the rgb to the grayscale value.
	return dot(color.rgb, vec3(1.0/3.0));
}


/*
shadowtex0 contains everything that casts a shadow
shadowtex1 contains only things which are fully opaque and cast a shadow
shadowcolor0 contains the color (including how transparent it is) of things which cast a shadow.
*/

vec3 getShadow(vec3 shadowScreenPos) {
	float transparentShadow = step(shadowScreenPos.z, texture(shadowtex0, shadowScreenPos.xy).r);  // sample the shadowmap containing everything
	
	/*
	note that a value of 1.0 means 100% of sunlight is getting through
	not that there is 100% shadowing
	*/

	// fully lit.
	if (transparentShadow == 1.0) {
		return vec3(1.0,1.0,1.0);
	}

	float opaqueShadow = step(shadowScreenPos.z, texture(shadowtex1, shadowScreenPos.xy).r); // sample the shadow map containing only opaque stuff

	if (opaqueShadow == 0.0){
		// there is a shadow cast by something opaque, so we return no sunlight
		return vec3(0.0,0.0,0.0);
	}

	// contains the color and alpha (transparency) of the thing casting a shadow
  	vec4 shadowColor = texture(shadowcolor0, shadowScreenPos.xy);


	/*
	we use 1 - the alpha to get how much light is let through
	and multiply that light by the color of the caster
	*/
	return shadowColor.rgb * vec3((1.0 - shadowColor.a));
}

vec4 getNoise(vec2 coord) {
	ivec2 screenCord = ivec2(coord * vec2(viewWidth, viewHeight));  // exact pixel coordinate in the screen
	ivec2 noiseCoord = screenCord % noiseTextureResolution;  // wrap to range of noiseTextureResolution
	return texelFetch(noisetex, noiseCoord, 0);

}

vec3 getSharpShadow(vec4 shadowClipPos) {
	shadowClipPos.z -= 0.001;  // fix shadow acne by biasing by a tiny amount.
	shadowClipPos.xyz = distortShadowClipPos(shadowClipPos.xyz);
	vec3 shadowNDCPos = shadowClipPos.xyz / shadowClipPos.w;
	vec3 shadowScreenPos = shadowNDCPos * 0.5 + 0.5;
	return getShadow(shadowScreenPos);
}

vec3 getSoftShadow(vec4 shadowClipPos) {
	float noise = getNoise(texcoord).r;
	float theta = noise * radians(360.0); // random angle using noise value
	float cosTheta = cos(theta);
	float sinTheta = sin(theta);

	// matrix to rotate the offset around the original position by the angle
	mat2 rotation = mat2(cosTheta, -sinTheta, sinTheta, cosTheta);

	vec3 shadowAccum = vec3(1.0);
	const int samples = SHADOW_RANGE * SHADOW_RANGE * 4;  // 2*range*2*range samples
	
	for (int x=-SHADOW_RANGE; x<SHADOW_RANGE; x++ ) {
		for (int y=-SHADOW_RANGE; y<SHADOW_RANGE; y++){
			vec2 offset = vec2(x,y) * SHADOW_RADIUS / float(SHADOW_RANGE);
			offset *= rotation;  // rotate the sampling kernel by rotation matrix.
			offset /= shadowMapResolution;  // divide by res so the offset is in pixels
			vec4 offsetShadowClipPos = shadowClipPos + vec4(offset, 0.0,0.0);
			offsetShadowClipPos.z -= 0.001;
			offsetShadowClipPos.xyz = distortShadowClipPos(offsetShadowClipPos.xyz);  // apply distortion
			vec3 shadowNDCPos = offsetShadowClipPos.xyz / offsetShadowClipPos.w; // convert to NDC space
			vec3 shadowScreenPos = shadowNDCPos * 0.5 + 0.5; // convert to screen space
      		shadowAccum += getShadow(shadowScreenPos); // take shadow sample
		}
	}
	
	return shadowAccum / float(samples); // divide sum by count, getting average shadow
}

void main() {
	color = texture(colortex0, texcoord);
	color.rgb = pow(color.rgb, vec3(2.2));  // inv gamma correct

	float depth = texture(depthtex0, texcoord).r;
	if (depth == 1.0) {
		return;
	}

	vec2 lightmap = texture(colortex1, texcoord).rg; // we only need the r and g components
	vec3 encodedNormal = texture(colortex2, texcoord).rgb;
	vec3 normal = normalize((encodedNormal - 0.5) * 2.0); // we normalize to make sure it is of unit length


	// shadows !?!?!?
	vec3 lightVector = normalize(shadowLightPosition);
	// transform from normal to world space, we do this bcuz colortex is 8bit, so only 256 values which will create flickering.
	vec3 worldLightVector = mat3(gbufferModelViewInverse) * lightVector;

	vec3 NDCPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);
	vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
	vec3 shadowViewPos = (shadowModelView * vec4(feetPlayerPos, 1.0)).xyz;
	vec4 shadowClipPos = shadowProjection * vec4(shadowViewPos, 1.0);
	vec3 shadow = getSoftShadow(shadowClipPos);


	// light stuff idk
	vec3 blocklight = lightmap.r * getBlocklightColor(sunAngle);
	vec3 skylight = lightmap.g * getSkylightColor(sunAngle);
	vec3 ambient = getAmbientColor(sunAngle);
	// vec3 sunlight = sunlightColor * clamp(dot(worldLightVector, normal), 0.0, 1.0) * pow(shadow, vec3(2.2));
	vec3 sunlight = getSunlightColor(sunAngle) * clamp(dot(worldLightVector, normal), 0.0, 1.0) * shadow;


	color.rgb *= blocklight + skylight + ambient + sunlight;
	// color.rgb = getAmbientColor(sunAngle);
	// color.rgb = getNoise(texcoord).rgb;
	// color.rgb = texture(shadowtex0, texcoord).rgb;
}