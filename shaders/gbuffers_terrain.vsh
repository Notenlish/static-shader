#version 330 compatibility

uniform mat4 gbufferModelViewInverse;

out vec2 lmcoord;  // lightmap coordinates(stores block exposure and sky exposure)
out vec2 texcoord;  // coordinate in the texture atlas
out vec4 glcolor;  // color tint for blocks like leaves, grass etc.
out vec3 normal;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;  // range 0.033 - 0.97
	lmcoord = lmcoord / (30.0 / 32.0) - (1.0 / 32.0);  // the correct light level


	// gl_Normal is in model space, so we need to convert it to player space
	// aka. direction is relative to the orientation and position of the player, instead of the model (i.e the chunk being rendered)
	// world space has positions relative to (0,0) 
	// orientation of world and player space are the same.

	normal = gl_NormalMatrix * gl_Normal;  // normal in view space
	normal = mat3(gbufferModelViewInverse) * normal;

	glcolor = gl_Color;
}

