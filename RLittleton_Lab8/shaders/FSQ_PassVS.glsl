#version 450

layout (location = 0) in vec4 aPosition;

uniform mat4 uModelMat, uViewMat, uProjMat;

out vec2 vTexcoord;

void main() 
{
	gl_Position = aPosition;
	
	vTexcoord = gl_Position.xy;
}
