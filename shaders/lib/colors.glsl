#define PI 3.14


vec3 getSunlightColor(float sunAngle) {
    vec3 baseSunlightColor = vec3(1.0);

    float l = 0.5 + 0.5 * cos(2.0 * PI * (sunAngle - 0.25));

    return baseSunlightColor * vec3(l);
}

vec3 getAmbientColor(float sunAngle) {
    const vec3 ambientColor = vec3(0.1);

    float l = 0.5 + 0.5 * cos(2.0 * PI * (sunAngle - 0.25));

    return ambientColor * vec3(l);
}


vec3 getSkylightColor(float sunAngle) {
    const vec3 skylightColor = vec3(0.05, 0.15, 0.3);
    float l = 0.5 + 0.5 * cos(2.0 * PI * (sunAngle - 0.25));
    return skylightColor * vec3(l);
}

vec3 getBlocklightColor(float sunAngle) {
    const vec3 blocklightColor = vec3(1.0, 0.5, 0.08);
    float l = 0.8 + 0.2 * cos(2.0 * PI * (sunAngle - 0.25));
    return blocklightColor * vec3(l);
}