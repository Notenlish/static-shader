#version 330 compatibility

// can access colortex 0 to 15. https://shaders.properties/current/reference/buffers/colortex/
uniform sampler2D colortex0;

in vec2 texcoord;

// tells iris patcher to write back to colortex0
/* RENDERTARGETS: 0 */

// "color" will be written to colortex0.
layout(location = 0) out vec4 color;

// tell IRIS to use a different precision so we don't lose possible color values when writing linear color.
// (idk what linear color is, the docs told me to do this)
// by default colortex is rgba8.

/*
const int colortex0Format = RGB16;
*/


void main() {
	color = texture(colortex0, texcoord);
	color.rgb = pow(color.rgb, vec3(1.0 / 2.2));  // gamma correct
}