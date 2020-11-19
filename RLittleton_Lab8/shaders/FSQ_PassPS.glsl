#version 450

/*
Author: Ryan Littleton - using class code tutorial from Daniel Buckstein
Class : GPR-200-01
Assignment : Lab 8
*/

#ifdef GL_ES
precision highp float;
#endif // GL_ES

layout (location = 0) out vec4 rtFragColor;

uniform vec2 uResolution;

uniform sampler2D uTex; // 0 as integer

in vec2 vTexcoord;

void main() 
{
	vec2 uv = vTexcoord;
	
	//rtFragColor = vec4(uv, 0.0, 1.0);
	
	rtFragColor = texture(uTex, uv);
}