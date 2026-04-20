#version 330 compatibility

uniform sampler2D lightmap;
uniform sampler2D gtexture;
uniform sampler2D colortex2;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 normal;

/* RENDERTARGETS: 0,5 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 waternormals;

void main() {
	color = texture(gtexture, texcoord) * glcolor;
	color *= texture(lightmap, lmcoord);
	if (color.a < alphaTestRef) {
		discard;
	}
	color.b += 0.05;
	color.a += 0.05;

	waternormals = vec4(normal * 0.5 + 0.5, 1.0);
}