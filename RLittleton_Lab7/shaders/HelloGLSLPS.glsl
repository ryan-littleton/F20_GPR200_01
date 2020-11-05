#version 330

/*
Author: Ryan Littleton - using class code tutorial from Daniel Buckstein
Class : GPR-200-01
Assignment : Lab 7
*/

#ifdef GL_ES
precision highp float;
#endif // GL_ES

layout (location = 0) out vec4 rtFragColor;

// Varying
// Per-Vertex: receive final color
// in vec4 color;

// Per-Fragment: receive reqs for final color
in vec4 vNormal;
in vec2 vTexcoord;

void main() 
{
	//rtFragColor = vec4(1.0);
	
	// Per-Vertex input is final color
	// rtFragColor = vColor;
	
	// Per-Fragment inputs to calc final color
	vec4 N = normalize(vNormal);
	rtFragColor = vec4(N.xyz * 0.5 + 0.5, 1.0);
	//rtFragColor = vec4(vTexcoord, 0.0, 1.0);
}