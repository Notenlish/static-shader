#version 330 compatibility

uniform float frameTimeCounter; 
uniform vec3 cameraPosition;
uniform sampler2D noisetex;

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;

const float amplitude = 0.1;

void main() {
	vec4 p = gl_Vertex;
	p.y -= amplitude * 0.5;

	vec3 worldPos = p.xyz + cameraPosition;

	vec2 noiseCoord = worldPos.xz * 0.125;
	noiseCoord += vec2(frameTimeCounter * 0.01);
	float wave = texture(noisetex, noiseCoord).r;

	// float wave = sin(frameTimeCounter * speed * worldPos.x * freq + worldPos.z * freq);
	p.y += wave * amplitude;

	gl_Position = gl_ModelViewProjectionMatrix * p;

	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
}