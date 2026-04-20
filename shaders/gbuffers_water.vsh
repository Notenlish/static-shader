#version 330 compatibility

uniform mat4 gbufferModelViewInverse;

uniform float frameTimeCounter;
uniform vec3 cameraPosition;
uniform sampler2D noisetex;

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 normal;

in vec2 mc_Entity;

const float amplitude = 0.08;
const float speed = 0.9;

vec4 doWater(vec4 p) {
    p.y -= amplitude * 0.5;

    vec3 worldPos = p.xyz + cameraPosition;

    vec2 noiseCoord = worldPos.xz * 0.125;
    noiseCoord += vec2(frameTimeCounter * speed * 0.01);
    float wave = texture(noisetex, noiseCoord).r;

    // float wave = sin(frameTimeCounter * speed * worldPos.x * freq + worldPos.z * freq);
    p.y += wave * amplitude;
	return p;
}

void main() {
    vec4 p = gl_Vertex;

	// .y is 1 for fluids, -1 for other blocks
    if (mc_Entity.y == 1.0) {
        p = doWater(p);
    }

    gl_Position = gl_ModelViewProjectionMatrix * p;

    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    glcolor = gl_Color;

    normal = normalize(gl_NormalMatrix * gl_Normal);  // normal in view space
	// normal = mat3(gbufferModelViewInverse) * normal;
}

// I need to create a block.properties file and assign spesific id's to water
// that way if its only water/lava I can do it
