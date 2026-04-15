#version 330 compatibility

#include "/lib/colors.glsl"

uniform float sunAngle;
uniform sampler2D colortex0;
uniform sampler2D colortex3;

in vec2 texcoord;

/* RENDERTARGETS: 0,3 */  // this is the thing that matters
layout(location=0) out vec4 color;  // this just maps to the rendertarget index!?!
layout(location=1) out vec4 bloom;

void main() {
    color = texture(colortex0, texcoord);

    if (color.a < 0.1) {
        discard;
    }
    // vec3 hsl = rgb2hsl(color.rgb);
    float brightness = dot(color.rgb, vec3(0.2126, 0.7152, 0.0722));

    vec3 bloomColor = vec3(0);
    if (brightness > 0.999 * clamp(getMultiplier(sunAngle), 0.0, 1.0) + 0.25) {
        bloomColor = color.rgb;
    }

    // color.rgb = bloomColor;

    bloom = vec4(bloomColor, 1.0);
}
