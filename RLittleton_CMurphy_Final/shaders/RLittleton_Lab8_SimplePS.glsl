#version 450

/*
Author: Ryan Littleton & Cameron Murphy - using class code tutorial from Daniel Buckstein
Class : GPR-200-01
Assignment : Final
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
in vec4 vView;
in vec4 vPosition;

// holds point light data
struct pointLight
{
    vec4 center;
    vec4 color;
    float intensity;
};

// Varying for our lights
in pointLight[3] vLights;

// calcLight: calculates specular and diffuse for the light passed in
// doesn't need passed in parameters thanks to varyings
void calcLight(out vec3 finalColor)
{
    vec3 surfaceColor = texture(uSampler, vTexcoord.xy).xyz; // Set surface color to texture
    vec3 specReflectColor = vec3(1.0);

    float ambientIntensity = 0.1; // ambient light
    vec3 ambientColor = vec3(0.7, 0.2, 1.0); // global ambient light color
    
    vec3 vReflectTotal = vec3(0.0); // This will keep track of the total of all light influence
	
	// Loop for calculating lights
    for(int i = vLights.length() - 1; i >= 0; i--)
    {
   
        float fDiffuseIntensity; // diffuse for current light
    	float fSpecIntensity; // specular for current light
        
	    // Light direction to position
	    vec3 vLightDir;
	    vLightDir = vLights[i].center.xyz - vPosition.xyz;
	    vLightDir = normalize(vLightDir);
	    
	    // diffuse coefficient
	    float fDiffuseCoef = max(0.0, dot(vNormal.xyz, vLightDir));
	    float fDistanceToLight = distance(vLights[i].center.xyz, vPosition.xyz);
	
	    // attenuation
	    float fAIntensity = 1.0/(1.0 + fDistanceToLight / vLights[i].intensity + (fDistanceToLight * fDistanceToLight) / (vLights[i].intensity * vLights[i].intensity));
	
	    fDiffuseIntensity = fDiffuseCoef * fAIntensity; // Final diffuse intensity
	                
	    vec3 vHalfway = normalize(vLightDir + vView.xyz); // Halfway vector
	    float fSpecCoef = max(0.0, dot(vNormal.xyz, vHalfway)); // Spec coefficient Blinn-phong
	    float fHiExp = 64.0; // Highlight exponent
	    fSpecIntensity = pow(fSpecCoef, fHiExp * 4.0); // Blinn-Phong
        
        vReflectTotal += (fDiffuseIntensity * surfaceColor + fSpecIntensity * specReflectColor) *
            			vLights[i].color.xyz; // Add the current light calc to the sum
    }
    finalColor = vReflectTotal;
}

void main() 
{
	//rtFragColor = vec4(1.0);
	
	// Per-Vertex input is final color
	// rtFragColor = vColor;
	
	// Per-Fragment inputs to calc final color
	//vec4 N = normalize(vNormal);
	//rtFragColor = vec4(N.xyz * 0.5 + 0.5, 1.0);
	//rtFragColor = vTexcoord;
	//rtFragColor = texture(uSampler, vTexcoord.xy);
	
	//rtFragColor = vColor; // Vertex Lit
	
	vec3 finalColor;
	calcLight(finalColor);
	rtFragColor = vec4(finalColor, 1.0);
}