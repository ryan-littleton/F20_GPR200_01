#version 450

layout (location = 0) in vec4 aPosition;

uniform mat4 uModelMat, uViewMat, uProjMat;

out vec4 vPosClip;

void main() 
{
	//gl_Position = aPosition;
	// w = 1 because point
	
	//gl_Position = uModelMat * aPosition;
	// w = 1 because point
	
	//gl_Position = uViewMat * uModelMat * aPosition;
	// w = 1 because point; 
	
	gl_Position = uProjMat * uViewMat * uModelMat * aPosition;
	// w = 1 if orthographic, distance from viewer if perspective
	
	// Not Part of VS
	// NDC = CLIP / CLIP.W
	// w = 1
	// visible region is between -1 and 1
	
	vPosClip = gl_Position;
}
