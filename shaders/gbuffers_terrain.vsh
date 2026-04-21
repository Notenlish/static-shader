#version 330 compatibility

uniform mat4 gbufferModelViewInverse;

out vec2 lmcoord; // lightmap coordinates(stores block exposure and sky exposure)
out vec2 texcoord; // coordinate in the texture atlas
out vec4 glcolor; // color tint for blocks like leaves, grass etc.
out vec3 normal;

uniform float frameTimeCounter;

in vec2 mc_Entity;
in vec4 at_midBlock;
uniform int blockEntityId;

uniform vec3 cameraPosition;

#define SWAY_LEAVES
#define SWAY_GRASS
#define SWAY_SPEED 1.0 // [0.2 0.5 1.0 1.5 2.0]
#define SWAY_AMOUNT 1.0 // [0.5 0.75 1.0 1.5 2.0]
#define SWAY_SIZE 1.0 // [0.5 1.0 1.5 2.0]  // defines how long in world space coordinate it needs to be or smth idk i cant explain it

void main() {
    vec4 p = gl_Vertex;
    // vec4 p = ftransform();

    float time = frameTimeCounter;

    #ifdef SWAY_LEAVES
    if (int(round(mc_Entity.x)) == 1) {
        vec3 midBlockPos = at_midBlock.xyz / 64.0;
        float howHigh = (-midBlockPos.y) + 0.5; // 1.0 if the top of the leaf, otherwise 0.0
        howHigh = clamp(howHigh, 0.1, 1.0); // clamp to the 0.1 - 1.0 range so that the lower part still moves a bit

        vec3 worldPos = (gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex).xyz + cameraPosition;

        float input = ((time * 3.14 * 0.5) * SWAY_SPEED);
        p.x += sin((worldPos.z / (3.14 * SWAY_SIZE)) + input * 1.2) * 0.08 * howHigh * SWAY_AMOUNT;
        // p.y += cos(input) * 0.02;
        p.z -= cos(worldPos.x + input * 1.4) * 0.01 * howHigh * SWAY_AMOUNT;
    }
    #endif

    #ifdef SWAY_GRASS
    if (int(round(mc_Entity.x)) == 2) {
        vec3 midBlockPos = at_midBlock.xyz / 64.0;
        float howHigh = (-midBlockPos.y) + 0.5; // 1.0 if the top of the leaf, otherwise 0.0
        howHigh = clamp(howHigh, 0.1, 1.0); // clamp to 0.1 - 1.0 range so that the lower part still moves a bit

        vec3 worldPos = (gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex).xyz + cameraPosition;

        float input = ((time * 3.14 * 0.5) * SWAY_SPEED);
        p.x += sin((worldPos.z / (3.14 * SWAY_SIZE)) + input * 1.2) * 0.08 * howHigh * SWAY_AMOUNT;
        // p.y += cos(input) * 0.02;
        p.z -= cos(worldPos.x + input * 1.4) * 0.01 * howHigh * SWAY_AMOUNT;
    }
    #endif

    gl_Position = gl_ModelViewProjectionMatrix * p;
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy; // range 0.033 - 0.97
    lmcoord = lmcoord / (30.0 / 32.0) - (1.0 / 32.0); // the correct light level

    // gl_Normal is in model space, so we need to convert it to player space
    // aka. direction is relative to the orientation and position of the player, instead of the model (i.e the chunk being rendered)
    // world space has positions relative to (0,0)
    // orientation of world and player space are the same.

    normal = gl_NormalMatrix * gl_Normal; // normal in view space
    normal = mat3(gbufferModelViewInverse) * normal;

    glcolor = gl_Color;
}
