#version 330 compatibility

uniform float viewHeight;
uniform float viewWidth;

uniform sampler2D colortex0;
uniform sampler2D colortex3; // bloom stuff

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location=0) out vec4 color;

/*
https://www.shadertoy.com/view/Xltfzj
*/
void main() {
    // color = texture(colortex3, texcoord);
    
    float twoPi = 6.28318530718;

    // gaussian blur settings
    float directions = 16.0; // BLUR DIRECTIONS (Default 16.0 - More is better but slower)
    float quality = 4.0; // BLUR QUALITY (Default 3.0 - More is better but slower)
    float size = 16.0; // BLUR SIZE (Radius, default 8)

    vec2 radius = size / vec2(viewWidth, viewHeight);
    vec4 c = texture(colortex3, texcoord);

    // blur
    for (float d=0.0; d<twoPi; d+=twoPi/directions) {
        for (float i=1.0/quality; i<=1.0; i+=1.0/quality) {
            c += texture(colortex3, texcoord + vec2(cos(d), sin(d))*radius*i);
        }
    }

    c /= quality * directions - 15.0;
    c = clamp(c, vec4(0), vec4(1));

    // if (c.r < 0.01) {
    //     discard;
    // }

    // color = texture(colortex0, texcoord);
    // color = c;
    color = texture(colortex0, texcoord) + c;
}
