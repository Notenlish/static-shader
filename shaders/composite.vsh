#version 330 compatibility

// values passed from vertex to fragment are interpolated by default
// to make them not interpolated, use "flat" keyword.
out vec2 texcoord;


void main() {
	// (deprecated)
	// ftransform converts vertex pos from model space to clip space
	// clip space = when world model has frustum culling done
	gl_Position = ftransform();

	// texture coordinate (UV). From 0,0 to 1,1
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}