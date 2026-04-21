#version 330 compatibility

const int noiseTextureResolution = 128;

uniform float frameTimeCounter;
uniform float viewHeight;
uniform float viewWidth;

uniform sampler2D colortex0;
uniform sampler2D colortex5;
uniform sampler2D colortex2;
uniform sampler2D noisetex;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

#include "/lib/vhs.glsl"

void main() {
    #ifdef VHS_ENABLED
    vec2 scale = vec2(VHSRES.x / viewWidth, VHSRES.y / viewHeight);

    vec2 newUV = texcoord * scale;
    // vec2 newUV = texcoord;
    // vec2 newUV = vec2(0.0, 0.0);

    color = texture(colortex0, newUV);
    // color = vec4(1.0);
    #endif
}
