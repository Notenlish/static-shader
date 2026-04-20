/*
https://www.shadertoy.com/view/MdffD7
*/

// ichannel1 is noise
// ichannel0 is just the colortex0
#define V vec2(0.,1.)
#define PI 3.14159265
#define HUGE 1E9
#define VHSRES vec2(640, 480.0)  // normally 320x240
#define saturate(i) clamp(i,0.,1.)
#define lofi(i,d) floor(i/d)*d
#define validuv(v) (abs(v.x-0.5)<0.5&&abs(v.y-0.5)<0.5)

#define SAMPLES 4  // default 6

float v2random(vec2 uv) {
    return texture(noisetex, mod(uv, vec2(1.0))).x;
}

mat2 rotate2D(float t) {
    return mat2(cos(t), sin(t), -sin(t), cos(t));
}

vec3 rgb2yiq(vec3 rgb) {
    return mat3(0.299, 0.596, 0.211, 0.587, -0.274, -0.523, 0.114, -0.322, 0.312) * rgb;
}

vec3 yiq2rgb(vec3 yiq) {
    return mat3(1.000, 1.000, 1.000, 0.956, -0.272, -1.106, 0.621, -0.647, 1.703) * yiq;
}

vec3 vhsTex2D(vec2 uv, float rot) {
    if (validuv(uv)) {
        vec3 yiq = vec3(0.0);
        for (int i = 0; i < SAMPLES; i++) {
            yiq += (
                rgb2yiq(texture(colortex0, uv - vec2(float(i), 0.0) / VHSRES).xyz) *
                    vec2(float(i), float(SAMPLES - 1 - i)).yxx / float(SAMPLES - 1)
                ) / float(SAMPLES) * 2.0;
        }
        if (rot != 0.0) {
            yiq.yz = rotate2D(rot) * yiq.yz;
        }
        return yiq2rgb(yiq);
    }
    return vec3(0.1, 0.1, 0.1);
}