#version 450

/*
Author: Ryan Littleton
Class : GPR-200-01
Assignment : Final
*/

layout (location = 0) in vec4 aPosition;

uniform mat4 uModelMat, uViewMat, uProjMat;

out vec2 vTexcoord;

void main() 
{
	gl_Position = aPosition;
	
	vTexcoord = aPosition.xy * 0.5 + 0.5;
}
