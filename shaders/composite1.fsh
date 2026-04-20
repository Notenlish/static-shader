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

// --- Settings ---
const int MAX_STEPS = 40;
const float STEP_SIZE = 0.4;
const float THICKNESS = 0.5;
const float MAX_DISTANCE = 50.0;

// Helper: Convert depth and UV to View-Space Position
vec3 getViewPos(vec2 uv) {
    float depth = texture(depthtex0, uv).r;
    vec4 ndc = vec4(uv * 2.0 - 1.0, depth * 2.0 - 1.0, 1.0);
    vec4 viewPos = gbufferProjectionInverse * ndc;
    return viewPos.xyz / viewPos.w;
}

void main() {
    vec3 sceneCol = texture(colortex0, texcoord).rgb;
    float depth = texture(depthtex0, texcoord).r;

    // Skip sky (depth 1.0)
    if (depth >= 1.0) {
        color = vec4(sceneCol, 1.0);
        return;
    }

    // 1. Get View-Space Normal and Position
    // Note: Normal must be mapped from [0, 1] to [-1, 1]
    vec3 normal = normalize(texture(colortex5, texcoord).xyz * 2.0 - 1.0);
    vec3 viewPos = getViewPos(texcoord);

    // 2. Identify "Reflective" surfaces
    // Optimization: Only reflect surfaces pointing upward (like floors)
    bool isReflective = normal.y > 0.5;

    vec3 finalCol = sceneCol;

    if (isReflective) {
        vec3 reflectDir = reflect(normalize(viewPos), normal);
        vec3 rayPos = viewPos;

        // 3. Ray Marching
        for (int i = 0; i < MAX_STEPS; i++) {
            rayPos += reflectDir * STEP_SIZE;

            // Project current ray position back to screen UV
            vec4 proj = gbufferProjection * vec4(rayPos, 1.0);
            vec2 sampleUV = (proj.xy / proj.w) * 0.5 + 0.5;

            // Check if UV is off-screen
            if (sampleUV.x < 0.0 || sampleUV.x > 1.0 || sampleUV.y < 0.0 || sampleUV.y > 1.0) break;

            float sampledDepth = texture(depthtex0, sampleUV).r;
            vec3 hitPos = getViewPos(sampleUV);

            // Compare ray depth with scene depth
            // We use a "thickness" threshold to detect a hit
            float depthDiff = length(viewPos - rayPos) - length(viewPos - hitPos);

            if (depthDiff > 0.0 && depthDiff < THICKNESS) {
                // 4. Calculate Attenuation (Fade out at edges and distance)
                float edgeFade = smoothstep(0.0, 0.1, sampleUV.x) * smoothstep(1.0, 0.9, sampleUV.x) *
                        smoothstep(0.0, 0.1, sampleUV.y) * smoothstep(1.0, 0.9, sampleUV.y);

                float distFade = 1.0 - clamp(length(rayPos - viewPos) / MAX_DISTANCE, 0.0, 1.0);

                vec3 reflectionCol = texture(colortex0, sampleUV).rgb;
                finalCol = mix(sceneCol, reflectionCol, 0.5 * edgeFade * distFade);
                break;
            }
        }
    }

    // Apply gamma correction (approximate sRGB)
    // vec4 fragColor = vec4(pow(finalCol, vec3(1.0 / 2.2)), 1.0);

    color = vec4(finalCol, 1.0);
}
