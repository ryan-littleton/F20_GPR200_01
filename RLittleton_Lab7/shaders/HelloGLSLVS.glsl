#version 450
/*
Author: Ryan Littleton - using class code tutorial from Daniel Buckstein
Class : GPR-200-01
Assignment : Lab 7
*/

// This was a test to try includes, works but overly complex for our goal
// extension to enable including files
//#extension GL_GOOGLE_include_directive : enable
//#include <common.h>


// Main duty: read attributes
// 3D position in space
// uv: texture coordinate
// normal

// Object Space
layout (location = 0) in vec4 aPosition;
layout (location = 1) in vec3 aNormal;

// Texture Space
layout (location = 2) in vec4 aTexcoord;

// Transform Uniforms
uniform mat4 uModelMat;
uniform mat4 uViewMat;
uniform mat4 uProjMat;
uniform mat4 uViewProjMat;
uniform sampler2D uSampler;
uniform float uTime;

// Varying

// Per-Vertex: Final Color
out vec4 vColor;

// Per-Fragment: indiv. components
out vec4 vNormal;
out vec4 vTexcoord;

// View and position for lights
out vec4 vView; // View vector for lighting
out vec4 vPosition;

// holds point light data
struct pointLight
{
    vec4 center;
    vec4 color;
    float intensity;
};

// varying for lights
out pointLight[3] vLights;

// asPoint: promote a 3D vector into a 4D vector representing a point (w=1)
//    point: input 3D vector
// From D. Buckstein
vec4 asPoint(in vec3 point)
{
    return vec4(point, 1.0);
}

// inits the point light
void initPointLight(out pointLight light, in vec3 center, in vec4 color, in float intensity)
{
    light.center = asPoint(center);
    light.color = color;
    light.intensity = intensity;
}

// calcLight: calculates specular and diffuse for the light passed in
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
    finalColor = vReflectTotal; // set final color
}

void main()
{
	// Required: Set gl_Position
	// problem: gl_position is in clip space
	// problem: aPosition is in object space
	// gl_Position = aPosition NO
	
	// position in world space (still no)
	// vec4 pos_world = uModelMat * aPosition;
	// gl_Position = pos_world;
	
	// position in camera space (still no)
	// vec4 pos_camera = uViewMat * pos_world;
	// gl_Position = pos_camera;
	
	// position in clip space (yay)
	// vec4 pos_clip = uViewProjMat * pos_world;
	
	// Vertex Lighting via includes (not doing this)
	//pointLight light;
	//initPointLight(light, vec3(2.0), vec4(1.0), 5.0);
	
	// Final Pos Pipeline
	mat4 modelViewMat = uViewMat * uModelMat;
	vec4 pos_camera = modelViewMat * aPosition;
	vec4 pos_clip = uProjMat * pos_camera;
	gl_Position = pos_clip;
	
	// View to model space
	mat4 viewToModelMat = inverse(modelViewMat);
	
	// Normal Pipeline
	mat3 normalMatrix = transpose(inverse(mat3(modelViewMat)));
	vec3 norm_camera = normalMatrix * aNormal;
	
	// Texcoord Pipeline
	mat4 atlasMat = mat4(1.0, 0.0, 0.0, 0.0, // Change first value of this row to scale
						 0.0, 1.0, 0.0, 0.0, // Change second value of this row to scale
						 0.0, 0.0, 1.0, 0.0,
						 0.0, 0.0, 0.0, 1.0); // Change left two of this row to offset
	vec4 uv_atlas = atlasMat * aTexcoord;
	
	// Optionally write varyings
	// vColor = aPosition; etc.
	
	// Per-Fragment outputs
	vNormal = vec4(norm_camera, 0.0);
	//vTexcoord = aTexcoord;
	vTexcoord = uv_atlas;
	
	// Lighting 
    initPointLight(vLights[0], vec3(22.0 * sin(uTime), 6.0, -5.0), vec4(1.0), 30.0); // Mult by sin time to animate
    initPointLight(vLights[1], vec3(0.0, 20.0 * cos(uTime), 5.0), vec4(1.0), 30.0);
    initPointLight(vLights[2], vec3(-18.0 * sin(uTime), -4.0 * sin(uTime), -5.0), vec4(1.0), 30.0);

    vView = vec4(0.0, 0.0, -1.0, 0.0); // Negatize z aligned camera in view space
    // Converts vView to model space, giving us the correct view vector
    vView *= viewToModelMat;
    
    vPosition = aPosition * uModelMat;
    
    // Loop for transforming lights
    for(int i = vLights.length() - 1; i >= 0; i--)
    {
    	// Transforms lights to object space, comment out for view space
    	vLights[i].center.xyz = (vLights[i].center * viewToModelMat).xyz;
    }
    
    vec3 finalColor; // final color from lights
    calcLight(finalColor);
    vColor = vec4(finalColor, 1.0); // to vec4 and return

	
	// Unfolding tex 
	//gl_Position = uProjMat * modelViewMat * aTexcoord;

}