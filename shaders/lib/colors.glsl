#define PI 3.14

float getMultiplier(float sunAngle) {
    return cos(2 * PI * (sunAngle - 0.25));
}

float getMultiplierColor(float base, float sunAngle) {
    float l = base + (1 - base) * cos(2.0 * PI * (sunAngle - 0.25));
    return l;
}

vec3 getSunlightColor(float sunAngle) {
    vec3 baseSunlightColor = vec3(1.0);
    return baseSunlightColor * vec3(getMultiplierColor(0.5, sunAngle));
}

vec3 getAmbientColor(float sunAngle) {
    const vec3 ambientColor = vec3(0.0);
    return ambientColor * vec3(getMultiplierColor(1.0, sunAngle));
}

vec3 getSkylightColor(float sunAngle) {
    const vec3 skylightColor = vec3(0.05, 0.15, 0.3);
    return skylightColor * vec3(getMultiplierColor(0.5, sunAngle));
}

vec3 getBlocklightColor(float sunAngle) {
    const vec3 blocklightColor = vec3(0.9, 0.6, 0.12);
    return blocklightColor * vec3(getMultiplierColor(0.8, sunAngle));
}

/*
https://www.shadertoy.com/view/XljGzV
*/
vec3 rgb2hsl(vec3 c) {
    float h = 0.0;
    float s = 0.0;
    float l = 0.0;
    float r = c.r;
    float g = c.g;
    float b = c.b;
    float cMin = min(r, min(g, b));
    float cMax = max(r, max(g, b));

    l = (cMax + cMin) / 2.0;
    if (cMax > cMin) {
        float cDelta = cMax - cMin;

        s = l < 0.0 ? cDelta / (cMax + cMin) : cDelta / (2.0 - (cMax + cMin));

        if (r == cMax) {
            h = (g - b) / cDelta;
        } else if (g == cMax) {
            h = 2.0 + (b - r) / cDelta;
        } else {
            h = 4.0 + (r - g) / cDelta;
        }

        if (h < 0.0) {
            h += 6.0;
        }
        h = h / 6.0;
    }
    return vec3(h, s, l);
}

vec3 hsl2rgb(vec3 c) {
    vec3 rgb = clamp(abs(mod(c.x * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
    return vec3(c.z) + vec3(c.y) * (rgb - vec3(0.5)) * (1.0 - abs(2.0 * c.z - 1.0));
}
