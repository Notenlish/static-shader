#version 330 compatibility

uniform sampler2D lightmap;
uniform sampler2D gtexture;
uniform vec4 entityColor;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 normal;

/* RENDERTARGETS: 0,1,2 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 lightData;
layout(location = 2) out vec4 encodedNormal;

void main() {
	color = texture(gtexture, texcoord) * glcolor;
	
	// make it less yellow idfk
	color.r = clamp(color.r-0.05,0.0,1.0);
	color.g = clamp(color.g-0.05,0.0,1.0);

	color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a);
	if (color.a < alphaTestRef) {
		discard;
	}
	vec2 n = texture(lightmap, lmcoord).rg;
	lightData = vec4(n.r, n.g, 0.0, 1.0);
	encodedNormal = vec4(normal * 0.5 + 0.5, 1.0);  // convert from [-1,1] to [0,1]
}