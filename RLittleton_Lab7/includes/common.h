/*
Author: Ryan Littleton - using starter from Daniel Buckstein
Class : GPR-200-01
Assignment : Lab 7
*/
// GLSL STARTER CODE BY DANIEL S. BUCKSTEIN
//  -> COMMON TAB (shared with all other tabs)

//------------------------------------------------------------
// TYPE ALIASES & UTILITY FUNCTIONS

// sScalar: alias for a 1D scalar (non-vector)
#define sScalar float

// sCoord: alias for a 2D coordinate
#define sCoord vec2

// sDCoord: alias for a 2D displacement or measurement
#define sDCoord vec2

// sBasis: alias for a 3D basis vector
#define sBasis vec3

// sPoint: alias for a point/coordinate/location in space
#define sPoint vec4

// sVector: alias for a vector/displacement/change in space
#define sVector vec4


// color3: alias for a 3D vector representing RGB color
// 	(this is non-spatial so neither a point nor vector)
#define color3 vec3

// color4: alias for RGBA color, which is non-spatial
// 	(this is non-spatial so neither a point nor vector)
#define color4 vec4


// asPoint: promote a 3D vector into a 4D vector 
//	representing a point in space (w=1)
//    v: input 3D vector to be converted
sPoint asPoint(in sBasis v)
{
    return sPoint(v, 1.0);
}

// asVector: promote a 3D vector into a 4D vector 
//	representing a vector through space (w=0)
//    v: input 3D vector to be converted
sVector asVector(in sBasis v)
{
    return sVector(v, 0.0);
}


// lengthSq: calculate the squared length of a vector type
//    x: input whose squared length to calculate
sScalar lengthSq(sScalar x)
{
    return (x * x);
    //return dot(x, x); // for consistency with others
}
sScalar lengthSq(sDCoord x)
{
    return dot(x, x);
}
sScalar lengthSq(sBasis x)
{
    return dot(x, x);
}
sScalar lengthSq(sVector x)
{
    return dot(x, x);
}


//------------------------------------------------------------
// VIEWPORT INFO

// sViewport: info about viewport
//    viewportPoint: location on the viewing plane 
//							x = horizontal position
//							y = vertical position
//							z = plane depth (negative focal length)
//	  pixelCoord:    position of pixel in image
//							x = [0, width)	-> [left, right)
//							y = [0, height)	-> [bottom, top)
//	  resolution:    resolution of viewport
//							x = image width in pixels
//							y = image height in pixels
//    resolutionInv: resolution reciprocal
//							x = reciprocal of image width
//							y = reciprocal of image height
//	  size:       	 in-scene dimensions of viewport
//							x = viewport width in scene units
//							y = viewport height in scene units
//	  ndc: 			 normalized device coordinate
//							x = [-1, +1) -> [left, right)
//							y = [-1, +1) -> [bottom, top)
// 	  uv: 			 screen-space (UV) coordinate
//							x = [0, 1) -> [left, right)
//							y = [0, 1) -> [bottom, top)
//	  aspectRatio:   aspect ratio of viewport
//	  focalLength:   distance to viewing plane
struct sViewport
{
    sPoint viewportPoint;
	sCoord pixelCoord;
	sDCoord resolution;
	sDCoord resolutionInv;
	sDCoord size;
	sCoord ndc;
	sCoord uv;
	sScalar aspectRatio;
	sScalar focalLength;
};

// initViewport: calculate the viewing plane (viewport) coordinate
//    vp: 		      output viewport info structure
//    viewportHeight: input height of viewing plane
//    focalLength:    input distance between viewer and viewing plane
//    fragCoord:      input coordinate of current fragment (in pixels)
//    resolution:     input resolution of screen (in pixels)
void initViewport(out sViewport vp,
                  in sScalar viewportHeight, in sScalar focalLength,
                  in sCoord fragCoord, in sDCoord resolution)
{
    vp.pixelCoord = fragCoord;
    vp.resolution = resolution;
    vp.resolutionInv = 1.0 / vp.resolution;
    vp.aspectRatio = vp.resolution.x * vp.resolutionInv.y;
    vp.focalLength = focalLength;
    vp.uv = vp.pixelCoord * vp.resolutionInv;
    vp.ndc = vp.uv * 2.0 - 1.0;
    vp.size = sDCoord(vp.aspectRatio, 1.0) * viewportHeight;
    vp.viewportPoint = asPoint(sBasis(vp.ndc * vp.size * 0.5, -vp.focalLength));
}


//------------------------------------------------------------
// RAY INFO

// sRay: ray data structure
//	  origin: origin point in scene
//    direction: direction vector in scene
struct sRay
{
    sPoint origin;
    sVector direction;
};

// initRayPersp: initialize perspective ray
//    ray: 		   output ray
//    eyePosition: position of viewer in scene
//    viewport:    input viewing plane offset
void initRayPersp(out sRay ray,
             	  in sBasis eyePosition, in sBasis viewport)
{
    // ray origin relative to viewer is the origin
    // w = 1 because it represents a point; can ignore when using
    ray.origin = asPoint(eyePosition);

    // ray direction relative to origin is based on viewing plane coordinate
    // w = 0 because it represents a direction; can ignore when using
    ray.direction = asVector(viewport - eyePosition);
}

// initRayOrtho: initialize orthographic ray
//    ray: 		   output ray
//    eyePosition: position of viewer in scene
//    viewport:    input viewing plane offset
void initRayOrtho(out sRay ray,
             	  in sBasis eyePosition, in sBasis viewport)
{
    // offset eye position to point on plane at the same depth
    initRayPersp(ray, eyePosition + sBasis(viewport.xy, 0.0), viewport);
}

//------------------------------------------------------------
// MISC FUNCTIONS

// These rotation matrices from https://gist.github.com/onedayitwillmake/3288507
mat4 rotationX( in float angle ) {
    float cosAngle = cos(angle);
    float sinAngel = sin(angle);
	return mat4(	1.0,		0,			0,			0,
			 		0, 	cosAngle,	-sinAngel,		0,
					0, 	sinAngel,	 cosAngle,		0,
					0, 			0,			  0, 		1);
}

// These rotation matrices from https://gist.github.com/onedayitwillmake/3288507
mat4 rotationY( in float angle ) {
    float cosAngle = cos(angle);
    float sinAngel = sin(angle);
	return mat4(	cosAngle,		0,		sinAngel,	0,
			 				0,		1.0,			 0,	0,
					-sinAngel,	0,		cosAngle,	0,
							0, 		0,				0,	1);
}

// These rotation matrices from https://gist.github.com/onedayitwillmake/3288507
mat4 rotationZ( in float angle ) {
    float cosAngle = cos(angle);
    float sinAngel = sin(angle);
	return mat4(	cosAngle,		-sinAngel,	0,	0,
			 		sinAngel,		cosAngle,		0,	0,
							0,				0,		1,	0,
							0,				0,		0,	1);
}

float normpdf(in float x, in float sigma)
{
	return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma;
}

//------------------------------------------------------------
// LIGHTING FUNCTIONS

// Lighting functions from my lab 4
// holds point light data
struct pointLight
{
    vec4 center;
    vec4 color;
    float intensity;
};
    
// inits the point light
void initPointLight(out pointLight light, in vec3 center, in vec4 color, in float intensity)
{
    light.center = asPoint(center);
    light.color = color;
    light.intensity = intensity;
}

// calcLight: calculates specular and diffuse for the light passed in
//	  light: 			 input for the current light
//	  ray: 			     needed for view vector
//	  surfaceColor: 	 input for color
//	  p: 			 	 closest surface point along view ray
vec4 calcLight(in pointLight light, in sRay ray, in vec3 normal, in color4 surfaceColor, in vec3 p)
{
    vec3 vView = normalize(ray.origin.xyz - ray.direction.xyz); // view vector
    // Light direction to position
    vec3 vLightDir;
    vLightDir = light.center.xyz - p;
    vLightDir = normalize(vLightDir);
    
    // diffuse coefficient
    float fDiffuseCoef = max(0.0, dot(normal, vLightDir));
    float fDistanceToLight = distance(light.center.xyz, p);

    // attenuation
    float fAIntensity = 1.0/(1.0 + fDistanceToLight / light.intensity + (fDistanceToLight * fDistanceToLight) / (light.intensity * light.intensity));

    float fDiffuseIntensity = fDiffuseCoef * fAIntensity; // Final diffuse intensity
                
    vec3 vHalfway = normalize(vLightDir + vView); // Halfway vector
    float fSpecCoef = max(0.0, dot(normal, vHalfway)); // Spec coefficient Blinn-phong
    float fHiExp = 64.0; // Highlight exponent
    float fSpecIntensity = pow(fSpecCoef, fHiExp * 4.0); // Blinn-Phong
    vec3 specReflectColor = vec3(1.0);
    float ambientIntensity = 0.2;
    color3 ambientColor = surfaceColor.xyz;
    
    light.color.xyz; // Add the current light calc to the sum
    
    vec3 vReflectTotal = (fDiffuseIntensity * surfaceColor.xyz + fSpecIntensity * specReflectColor) *
                light.color.xyz;

        
    vec3 finalColor = ambientIntensity * ambientColor + vReflectTotal; // final color from ambient and lights
    return vec4(finalColor, 1.0); // to vec4 and return
}
//------------------------------------------------------------
/*
// GLSL FRAGMENT SHADER STRUCTURE WITH COMMON TAB
//  -> This is (likely) how Shadertoy compiles buffer tabs:

// latest version or whichever is used
#version 300 es

// PROGRAM UNIFORMS (see 'Shader Inputs' dropdown)

// **CONTENTS OF COMMON TAB PASTED HERE**

// **CONTENTS OF BUFFER TAB PASTED HERE**

// FRAGMENT SHADER INPUTS (more on this later)

// FRAGMENT SHADER OUTPUTS (framebuffer render target(s))
//out vec4 rtFragColor; // no specific target
layout (location = 0) out vec4 rtFragColor; // default

void main()
{
    // Call 'mainImage' in actual shader main, which is 
	// 	our prototyping interface for ease of use.
	//		rtFragColor:  shader output passed by reference,
	//			full vec4 read in 'mainImage' as 'fragColor'
	//		gl_FragCoord: GLSL's built-in pixel coordinate,
	//			vec2 part read in 'mainImage' as 'fragCoord'
    mainImage(rtFragColor, gl_FragCoord.xy);
}
*/
