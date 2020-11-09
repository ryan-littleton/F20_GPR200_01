#version 450

#ifdef GL_ES
precision highp float;
#endif // GL_ES

layout (location = 0) out vec4 rtFragColor;

in vec4 vPosClip;

void main() 
{
	//rtFragColor = vec4(1.0);
	//rtFragColor = vPosClip;
	
	// Manual Perspective Divide for NDC
	vec4 posNDC = vPosClip / vPosClip.w;
	//rtFragColor = posNDC;

	// Screen-Space
	vec4 posScreen = posNDC * 0.5 + 0.5;
	rtFragColor = posScreen;
	//rtFragColor.b = 0.0; // remove blue to see RGY gradient
}