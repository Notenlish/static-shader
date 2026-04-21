#version 330 compatibility

uniform sampler2D colortex0; // Main Color
uniform sampler2D colortex5; // normals for water(viewspace)
uniform sampler2D depthtex0; // Depth Buffer

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;

in vec2 texcoord;

/* RENDERTARGETS: 0,5 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 waternormals;

#define MAX_STEPS 40 // [10 20 40 80 160]
#define STEP_SIZE 0.4  // [0.1 0.2 0.4 0.8]
#define THICKNESS 0.5  // [0.1 0.2 0.4 0.5 1.0]
#define MAX_DISTANCE 50.0  // [50.0 75.0 100.0 150.0]

/*
https://www.shadertoy.com/view/3lyXRt
*/
vec3 getViewPos(vec2 uv) {
    float depth = texture(depthtex0, uv).r;
    vec4 ndc = vec4(uv * 2.0 - 1.0, depth * 2.0 - 1.0, 1.0);
    vec4 viewPos = gbufferProjectionInverse * ndc;
    return viewPos.xyz / viewPos.w;
}

void main() {
    vec3 sceneCol = texture(colortex0, texcoord).rgb;
    float depth = texture(depthtex0, texcoord).r;

    if (depth >= 1.0) {
        color = vec4(sceneCol, 1.0);
        return;
    }

    vec3 normal = normalize(texture(colortex5, texcoord).xyz * 2.0 - 1.0);
    vec3 viewPos = getViewPos(texcoord);

    bool isReflective = normal.y > 0.5;

    vec3 finalCol = sceneCol;

    if (isReflective) {
        vec3 reflectDir = reflect(normalize(viewPos), normal);
        vec3 rayPos = viewPos;

        for (int i = 0; i < MAX_STEPS; i++) {
            rayPos += reflectDir * STEP_SIZE;

            vec4 proj = gbufferProjection * vec4(rayPos, 1.0);
            vec2 sampleUV = (proj.xy / proj.w) * 0.5 + 0.5;

            if (sampleUV.x < 0.0 || sampleUV.x > 1.0 || sampleUV.y < 0.0 || sampleUV.y > 1.0) break;

            float sampledDepth = texture(depthtex0, sampleUV).r;
            vec3 hitPos = getViewPos(sampleUV);

            float depthDiff = length(viewPos - rayPos) - length(viewPos - hitPos);

            if (depthDiff > 0.0 && depthDiff < THICKNESS) {
                float edgeFade = smoothstep(0.0, 0.1, sampleUV.x) * smoothstep(1.0, 0.9, sampleUV.x) *
                        smoothstep(0.0, 0.1, sampleUV.y) * smoothstep(1.0, 0.9, sampleUV.y);

                float distFade = 1.0 - clamp(length(rayPos - viewPos) / MAX_DISTANCE, 0.0, 1.0);

                vec3 reflectionCol = texture(colortex0, sampleUV).rgb;
                finalCol = mix(sceneCol, reflectionCol, 0.5 * edgeFade * distFade);
                break;
            }
        }
    }
    color = vec4(finalCol, 1.0);
}
