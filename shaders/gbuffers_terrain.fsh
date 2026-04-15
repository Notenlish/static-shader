#version 330 compatibility

uniform sampler2D lightmap;  // by default, minecraft uses a texture with colors for each light level. However we wont be using it
uniform sampler2D gtexture;  // texture atlas

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 normal;

/* RENDERTARGETS: 0,1,2 */
layout(location = 0) out vec4 color;  // write to colortex0
layout(location = 1) out vec4 lightmapData;  // write to colortex1
layout(location = 2) out vec4 encodedNormal;  // write to colortex2

void main() {
	color = texture(gtexture, texcoord) * glcolor;  // biome tint
	if (color.a < alphaTestRef) {
		discard;
	}

	lightmapData = vec4(lmcoord, 0.0, 1.0);
	encodedNormal = vec4(normal * 0.5 + 0.5, 1.0);  // convert from [-1,1] to [0,1]
}

