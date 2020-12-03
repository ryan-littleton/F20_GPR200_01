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

// calcToneMap: calculate the tonemap
vec4 calcToneMap(in vec2 fragCoord)
{
    // Followed this tutorial for tone mapping https://learnopengl.com/Advanced-Lighting/HDR
    const float gamma = 2.2;
    float exposure = 1.0;
    vec3 hdrColor = texture(uTex, vTexcoord).rgb;
  
    // exposure tone mapping
    vec3 mapped = vec3(1.0) - exp(-hdrColor * exposure);
    // gamma correction 
    mapped = pow(mapped, vec3(1.0 / gamma));
    
    // This is a modified version of https://learnopengl.com/Advanced-Lighting/Bloom
    vec4 brightColor;
    // gets brightness from the tone mapped color by converting to greyscale
    float brightness = dot(mapped.rgb, vec3(0.2126, 0.7152, 0.0722));
    // set the value for what is considered bright. 
    // if this was HDR, using 1 would be a good starting point as brightness could be above 1.
    if(brightness > 0.78)
        brightColor = vec4(mapped.rgb, 1.0);
    else
        brightColor = vec4(0.0, 0.0, 0.0, 1.0);
  
    return vec4(brightColor); // return the bright pass
}

void main() 
{
	vec2 uv = vTexcoord;
	
	//rtFragColor = vec4(uv, 0.0, 1.0);
	
	rtFragColor = calcToneMap(uv);
}