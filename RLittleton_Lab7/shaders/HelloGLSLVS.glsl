#version 450

/*
Author: Ryan Littleton - using class code tutorial from Daniel Buckstein
Class : GPR-200-01
Assignment : Lab 7
*/

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

// Varying

// Per-Vertex: Final Color
// out vec4 vColor;

// Per-Fragment: indiv. components
out vec4 vNormal;
out vec4 vTexcoord;

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
	
	// Final Pos Pipeline
	mat4 modelViewMat = uViewMat * uModelMat;
	vec4 pos_camera = modelViewMat * aPosition;
	vec4 pos_clip = uProjMat * pos_camera;
	gl_Position = pos_clip;
	
	// Normal Pipeline
	mat3 normalMatrix = transpose(inverse(mat3(modelViewMat)));
	vec3 norm_camera = normalMatrix * aNormal;
	
	// Texcoord Pipeline
	mat4 atlasMat = mat4(0.5, 0.0, 0.0, 0.0,
						 0.0, 0.5, 0.0, 0.0,
						 0.0, 0.0, 1.0, 0.0,
						 0.0, 0.0, 0.0, 1.0); // Change left two of this row to scale
	vec4 uv_atlas = atlasMat * aTexcoord;
	
	// Optionally write varyings
	// vColor = aPosition; etc.
	
	// Per-Fragment outputs
	vNormal = vec4(norm_camera, 0.0);
	//vTexcoord = aTexcoord;
	vTexcoord = uv_atlas;
	
	// Unfolding tex 
	//gl_Position = uProjMat * modelViewMat * aTexcoord;

}