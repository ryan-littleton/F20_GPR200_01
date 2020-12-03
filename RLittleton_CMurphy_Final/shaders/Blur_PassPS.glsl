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
uniform sampler2D uTex1; // 1 as integer

in vec2 vTexcoord;

float normpdf(in float x, in float sigma)
{
	return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma;
}

// This blur function is taken from https://www.shadertoy.com/view/XdfGDH
// calcBlur: calculate the blur
vec4 calcBlur(in vec2 fragCoord)
{
		//declare stuff
		const int mSize = 11;
		const int kSize = (mSize-1)/2;
		float kernel[mSize];
		vec3 final_colour = vec3(0.0);
		
		//create the 1-D kernel
		float sigma = 7.0;
		float Z = 0.0;
		for (int j = 0; j <= kSize; ++j)
		{
			kernel[kSize+j] = kernel[kSize-j] = normpdf(float(j), sigma);
		}
		
		//get the normalization factor (as the gaussian has been clamped)
		for (int j = 0; j < mSize; ++j)
		{
			Z += kernel[j];
		}
		
		//read out the texels
		for (int i=-kSize; i <= kSize; ++i)
		{
			for (int j=-kSize; j <= kSize; ++j)
			{
				final_colour += kernel[kSize+j]*kernel[kSize+i]
                    *texture(uTex, vTexcoord).rgb;
			}
		}
		
		return vec4(final_colour/(Z*Z), 1.0);
}

void main() 
{
	vec2 uv = vTexcoord;
	
	//rtFragColor = vec4(uv, 0.0, 1.0);
	
	//rtFragColor = texture(uTex1, uv);
	
	vec4 blur = calcBlur(uv);
	vec4 scene = texture(uTex1, uv);
	
	blur += scene;
	
	rtFragColor = blur;
}