#version 330 compatibility

const int noiseTextureResolution = 128;

uniform float frameTimeCounter;
uniform float viewHeight;
uniform float viewWidth;

uniform sampler2D colortex0;
uniform sampler2D noisetex;

in vec2 texcoord;

#define VHS_SPEED 10 // [1 2 3 5 8 10 20]
#define VHS_ENABLED

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

#include "/lib/vhs.glsl"

void main() {
    #ifdef VHS_ENABLED
    vec2 fragCoord = texcoord * vec2(viewWidth, viewHeight);
    vec2 uv = fragCoord.xy / VHSRES;
    // vec2 uv = texcoord;

    float time = frameTimeCounter * VHS_SPEED * 0.1;

    vec2 uvn = uv;
    vec3 col = vec3(0.0, 0.0, 0.0);

    // tape wave
    uvn.x += (v2random(vec2(uvn.y / 10.0, time / 10.0) / 1.0) - 0.5) / VHSRES.x * 1.0;
    uvn.x += (v2random(vec2(uvn.y, time * 10.0)) - 0.5) / VHSRES.x * 1.0;

    // tape crease
    float tcPhase = smoothstep(0.9, 0.96, sin(uvn.y * 8.0 - (time + 0.14 * v2random(time * vec2(0.67, 0.59))) * PI * 1.2));
    float tcNoise = smoothstep(0.3, 1.0, v2random(vec2(uvn.y * 4.77, time)));
    float tc = tcPhase * tcNoise;
    uvn.x = uvn.x - tc / VHSRES.x * 8.0;

    // switching noise
    float snPhase = smoothstep(6.0 / VHSRES.y, 0.0, uvn.y);
    uvn.y += snPhase * 0.3;
    uvn.x += snPhase * ((v2random(vec2(uv.y * 100.0, time * 10.0)) - 0.5) / VHSRES.x * 24.0);

    // fetch
    col = vhsTex2D(uvn, tcPhase * 0.2 + snPhase * 2.0);

    // crease noise
    float cn = tcNoise * (0.3 + 0.7 * tcPhase);
    if (0.8 < cn) {
        vec2 uvt = (uvn + V.yx * v2random(vec2(uvn.y, time))) * vec2(0.1, 1.0);
        float n0 = v2random(uvt);
        float n1 = v2random(uvt + V.yx / VHSRES.x);
        if (n1 < n0) {
            col = mix(col, 2.0 * V.yyy, pow(n0, 10.0));
        }
    }

    // ac beat
    col *= 1.0 + 0.1 * smoothstep(0.4, 0.6, v2random(vec2(0.0, 0.1 * (uv.y + time * 0.2)) / 10.0));

    // color noise
    col *= 0.9 + 0.1 * texture(noisetex, mod(uvn * vec2(1.0, 1.0) + time * vec2(5.97, 4.45), vec2(1.0))).xyz;
    col = saturate(col);

    // yiq
    col = rgb2yiq(col);
    // col = vec3(0.1, -0.1, 0.0) + vec3(0.9, 1.1, 1.5) * col;
    col = yiq2rgb(col);

    color = vec4(col, 1.0);
    #endif
}
