#version 450

/*
Author: Ryan Littleton - using class code tutorial from Daniel Buckstein
Class : GPR-200-01
Assignment : Lab 7
*/

#ifdef GL_ES
precision highp float; // don't need this in glsl but makes switching to es easy
#endif // GL_ES
// Input
layout (location = 0) out vec4 rtFragColor;
// Uniforms
uniform sampler2D uSampler;

// Varying
// Per-Vertex: receive final color
in vec4 vColor;

// Per-Fragment: receive reqs for final color
in vec4 vNormal;
in vec4 vTexcoord;

void main() 
{
	//rtFragColor = vec4(1.0);
	
	// Per-Vertex input is final color
	// rtFragColor = vColor;
	
	// Per-Fragment inputs to calc final color
	vec4 N = normalize(vNormal);
	rtFragColor = vec4(N.xyz * 0.5 + 0.5, 1.0);
	rtFragColor = vTexcoord;
	rtFragColor = texture(uSampler, vTexcoord.xy);
	rtFragColor = vColor;
}