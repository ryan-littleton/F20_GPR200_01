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
uniform float uTime;

// Varying
// Per-Vertex: receive final color
in vec4 vColor;

// Per-Fragment: receive reqs for final color
in vec4 vNormal;
in vec4 vTexcoord;

// GLSL lighting starter stuff from Lab 4

// holds point light data
struct pointLight
{
    vec4 center;
    vec4 color;
    float intensity;
};

// calcLight: calculates specular and diffuse for the light passed in
//    fDiffuseIntensity: output for the diffuse
//    fSpecIntensity:    output for the specular
//	  normal: 			 input for sphere normal
//	  position: 		 input for position on sphere
//	  normal: 			 input for view vector
//	  normal: 			 input for the current light
void calcLight(out float fDiffuseIntensity, out float fSpecIntensity, in vec3 normal, in vec3 position, in vec3 vView, in pointLight light)
{
    // Light direction to position
    vec3 vLightDir;
    vLightDir = light.center.xyz - position;
    vLightDir = normalize(vLightDir);
    
    // diffuse coefficient
    float fDiffuseCoef = max(0.0, dot(normal, vLightDir));
    float fDistanceToLight = distance(light.center.xyz, position);

    // attenuation
    float fAIntensity = 1.0/(1.0 + fDistanceToLight / light.intensity + (fDistanceToLight * fDistanceToLight) / (light.intensity * light.intensity));

    fDiffuseIntensity = fDiffuseCoef * fAIntensity; // Final diffuse intensity
                
    vec3 vHalfway = normalize(vLightDir + vView); // Halfway vector
    float fSpecCoef = max(0.0, dot(normal, vHalfway)); // Spec coefficient Blinn-phong
    float fHiExp = 64.0; // Highlight exponent
    fSpecIntensity = pow(fSpecCoef, fHiExp * 4.0); // Blinn-Phong
}

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