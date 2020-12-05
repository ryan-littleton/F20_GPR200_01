#version 450

/*
Author: Ryan Littleton - using class code tutorial from Daniel Buckstein
Class : GPR-200-01
Assignment : Final
*/

#ifdef GL_ES
precision highp float;
#endif // GL_ES

layout (location = 0) out vec4 rtFragColor;

uniform vec2 uResolution;
uniform float uTime;

uniform sampler2D uTex; // 0 as integer

in vec2 vTexcoord;

// GLSL STARTER CODE BY DANIEL S. BUCKSTEIN
//  -> COMMON TAB (shared with all other tabs)

//------------------------------------------------------------
// CONSTANTS
// used in SDF calculations

const int MAX_MARCHING_STEPS = 255;
const float MIN_DIST = 0.0;
const float MAX_DIST = 100.0;
const float EPSILON = 0.0001;

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
// SIGNED DISTANCE FIELD FUNCTIONS
// Followed this tutorial on raymarching and SDF 
// http://jamie-wong.com/2016/07/15/ray-marching-signed-distance-functions/

// sphereSDF: calculates sphere sdf
//	  p: 			 	 input for the sphere center
//	  r: 			 	 input for the sphere radius
float sphereSDF(in vec3 p, in float r) 
{
    return length(p) - r;
}

// sphereSDF: calculates sphere sdf with a radius of 1
//	  p: 			 	 input for the sphere center
float sphereSDF(in vec3 p) 
{
    return sphereSDF(p, 1.0);
}

// SDF distance calculations are based on ones from 
// https://iquilezles.org/www/articles/distfunctions/distfunctions.htm

// boxSDF: calculates box sdf with bounds b
//	  p: 			 	 box center
//	  b: 			 	 x,y,z bounds of the box
float boxSDF(in vec3 p, in vec3 b)
{
  	vec3 q = abs(p) - b;
  	return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

// cubeSDF: calculates box sdf with same bounds on all sides
//	  p: 			 	 input for the center point
//	  s: 			 	 input for the size
float cubeSDF(in vec3 p, in float s)
{
	return boxSDF(p, vec3(s));
}

float linkSDF( vec3 p, float le, float r1, float r2 )
{
  	vec3 q = vec3( p.x, max(abs(p.y)-le,0.0), p.z );
  	return length(vec2(length(q.xy)-r1,q.z)) - r2;
}

float repeatLinkSDF( in vec3 p, in vec3 c)
{
    vec3 q = mod(p+0.5*c,c)-0.5*c;
    return linkSDF(q, 0.5, 1.0, 0.3);
}

vec3 repeatSDF(in vec3 p, in vec3 c)
{
	vec3 q = mod(p+0.5*c,c)-0.5*c;
    return q;   
}

vec3 bendSDF(in vec3 p, float amt)
{
    float k = amt; // or some other amount
    float c = cos(k*p.x);
    float s = sin(k*p.x);
    mat2  m = mat2(c,-s,s,c);
    vec3  q = vec3(m*p.xy,p.z);
    return q;
}

// Constructive Solid Geometry functions
// Followed this tutorial on raymarching and SDF 
// http://jamie-wong.com/2016/07/15/ray-marching-signed-distance-functions/

// CSG functions use the same arguments, calculated with the SDF functions above
//	  a: 			 	 first object sdf
//	  b: 			 	 second object sdf

// intersectSDF: returns the intersecting areas of a and b
float intersectSDF(in float a, in float b) 
{
    return max(a, b);
}

// unionSDF: combines a and b geometry
float unionSDF(in float a, in float b) 
{
    return min(a, b);
}

// differenceSDF: removes geometry where a and b overlap
float differenceSDF(in float a, in float b) 
{
    return max(a, -b);
}

// viewMatrix: converts ray from view to world space, assumes target is origin, and up is up.
//	  eyePosition: 			the eye position
mat4 viewMatrix(in sBasis eyePosition) 
{
    vec3 target = vec3(0.0);
    vec3 up = vec3(0.0, 1.0, 0.0);
	vec3 f = normalize(target - eyePosition);
	vec3 s = normalize(cross(f, up));
	vec3 u = cross(s, f);
	return mat4(
		vec4(s, 0.0),
		vec4(u, 0.0),
		vec4(-f, 0.0),
		vec4(0.0, 0.0, 0.0, 1)
	);
}

// viewMatrix: converts ray from view to world space, takes in a target.
//	  eyePosition: 			the eye position
//	  target: 				the target position
mat4 viewMatrix(in sBasis eyePosition, in vec3 target) 
{
    vec3 up = vec3(0.0, 1.0, 0.0);
	vec3 f = normalize(target - eyePosition);
	vec3 s = normalize(cross(f, up));
	vec3 u = cross(s, f);
	return mat4(
		vec4(s, 0.0),
		vec4(u, 0.0),
		vec4(-f, 0.0),
		vec4(0.0, 0.0, 0.0, 1)
	);
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

//------------------------------------------------------------
// SIGNED DISTANCE FIELD FUNCTIONS
// Followed this tutorial on raymarching and SDF 
// http://jamie-wong.com/2016/07/15/ray-marching-signed-distance-functions/
// Since sceneSDF is what creates the scene, it and functions dependent
// on it will be here and not in common

// sceneSDF1-5: calculates a scene using sdf functions, each does a different thing
//	  point: 			 input for the current point
//	  fTime: 			 time for animation

// Animated repeating links
float sceneSDF1(in vec3 p, in float fTime)
{
    float finalSDF;
    float sphere1 = sphereSDF(p);
    float cube1 = cubeSDF(p, 0.8);
    float repeatLinks = linkSDF(repeatSDF(p, vec3( 5.0 + sin(fTime))), 0.5, 1.0, 0.3);
    float step1 = unionSDF(repeatLinks, sphere1);
    float step2 = differenceSDF(cube1, step1);
    finalSDF = unionSDF(repeatLinks, step2);
    return finalSDF;
}

// cube of links based on intersect around a sphere
float sceneSDF2(in vec3 p, in float fTime)
{
    float finalSDF;
    float sphere1 = sphereSDF(p);
    float cube1 = cubeSDF(p, 3.0);
    float repeatLinks = repeatLinkSDF(p, vec3( 2.0 + sin(fTime)));
    float step1 = intersectSDF(repeatLinks, cube1);
    float step2 = differenceSDF(sphere1, step1);
    finalSDF = unionSDF(step1, step2);
    return finalSDF;
}

// repeating intersected sphere, shows how patterns can be repeated
float sceneSDF3(in vec3 p, in float fTime)
{
    float finalSDF;
    vec3 inf = repeatSDF(p, vec3(4.0));
    float sphere1 = sphereSDF(inf);
    float cube1 = cubeSDF(inf, 0.8);
    float step1 = differenceSDF(sphere1, cube1);
    float step2 = intersectSDF(sphere1, step1);
    finalSDF = intersectSDF(step1, step2);
    return finalSDF;
}

// combining multiple vector manipulators for a trippy bend
float sceneSDF4(in vec3 p, in float fTime)
{
    float finalSDF;
    vec3 pBend = bendSDF(p, 0.1 * sin(fTime));
    vec3 inf = repeatSDF(pBend, vec3(4.0));
    float link1 = linkSDF(inf, 0.5, 1.0, 0.3);
    vec3 inf2 = repeatSDF(vec3(pBend.x, pBend.y + 1.8, pBend.z), vec3(4.0));
    vec4 rot = vec4(inf2, 1.0);
    rot *= rotationY(1.0);
    inf2 = rot.xyz;
    float link2 = linkSDF(inf2, 0.5, 1.0, 0.3);
    finalSDF = unionSDF(link1, link2);
    return finalSDF;
}

// basic union demo
float sceneSDF5(in vec3 p, in float fTime)
{
    float finalSDF;
    float sphere1 = sphereSDF(p);
    float cube1 = cubeSDF(p, 0.8);
    finalSDF = unionSDF(sphere1, cube1);
    return finalSDF;
}

//basic difference demo
float sceneSDF6(in vec3 p, in float fTime)
{
    float finalSDF;
    float sphere1 = sphereSDF(p);
    float cube1 = cubeSDF(p, 0.8);
    finalSDF = differenceSDF(sphere1, cube1);
    return finalSDF;
}

//basic intersect demo
float sceneSDF7(in vec3 p, in float fTime)
{
    float finalSDF;
    float sphere1 = sphereSDF(p);
    float cube1 = cubeSDF(p, 0.8);
    finalSDF = intersectSDF(sphere1, cube1);
    return finalSDF;
}

// replace the num in the function call below to change
float sceneSDF(in vec3 p, in float fTime) 
{
    
    return sceneSDF1(p, fTime);
}

// shortestDistanceToSurface: calcs shortest distance from eyePosition to surface
//	  eye: 			 input for the eye position
//	  rayDirection:  input for the ray direction
//	  start:  		 starting distance from the eye position
//	  end:  		 max distance to march
float shortestDistanceToSurface(in vec3 eyePosition, in vec3 rayDirection, in float start, in float end, in float fTime) 
{
    float depth = start;
    
    for (int i = 0; i < MAX_MARCHING_STEPS; i++) {
        
        float dist = sceneSDF(eyePosition + depth * rayDirection, fTime);
        
        if (dist < EPSILON) 
        {
			return depth;
        }
        
        depth += dist;
        
        if (depth >= end) 
        {
            return end;
        }
    }
    return end;
}

// estimateNormal: calculates an estimate normal from sdf
//	  p: 			 input for the current point along surface
vec3 estimateNormal(in vec3 p, in float fTime) 
{
    return normalize(vec3(
        sceneSDF(vec3(p.x + EPSILON, p.y, p.z), fTime) - sceneSDF(vec3(p.x - EPSILON, p.y, p.z), fTime),
        sceneSDF(vec3(p.x, p.y + EPSILON, p.z), fTime) - sceneSDF(vec3(p.x, p.y - EPSILON, p.z), fTime),
        sceneSDF(vec3(p.x, p.y, p.z  + EPSILON), fTime) - sceneSDF(vec3(p.x, p.y, p.z - EPSILON), fTime)
    ));
}


void main() 
{
	vec2 uv = vTexcoord;

    // viewing plane (viewport) inputs
    //const sBasis eyePosition = sBasis(5.0, 2.0, 1.5);
    const sScalar viewportHeight = 2.0, focalLength = 1.0;

    // Rotate objects by moving the mouse
	sBasis eyePosition = sBasis(0.0, 0.0, 5.5);
    vec4 eyeRot = vec4(eyePosition, 1.0);
    eyeRot *= rotationY(0.0) * rotationX(0.0);
    eyePosition.xyz = eyeRot.xyz;

    // viewport info
    sViewport vp;

    // ray
    sRay ray;
    
    // render
    initViewport(vp, viewportHeight, focalLength, gl_FragCoord.xy, uResolution.xy);
    initRayPersp(ray, vec3(0.0), vp.viewportPoint.xyz);
    

   	// getting negative z aligned view for setting world direction
    vec3 vView = normalize(vec3(ray.origin.xyz - ray.direction.xyz));
    vView.z = -vView.z;
    
    // use viewmatrix to center view on the target
    mat4 viewToWorld = viewMatrix(eyePosition);
    vec3 worldDir = (viewToWorld * vec4(vView, 0.0)).xyz;
    
    // Animating light
    vec3 lightPos = vec3(eyePosition.x * sin(uTime),
                          eyePosition.y,
                          eyePosition.z * cos(uTime));
    pointLight light;
    initPointLight(light, lightPos, vec4(1.0), 10.0);

    // Calc distance to surface
    float dist = shortestDistanceToSurface(eyePosition, worldDir, MIN_DIST, MAX_DIST, uTime);
    
    // If dist is greater than max nothing there
    if (dist > MAX_DIST - EPSILON) 
    {
        rtFragColor = vec4(0.0, 0.0, 0.0, 1.0); // Background buffer
		return;
    }
    
    // Closest point on surface from eye position along ray direction
    vec3 p = eyePosition + dist * worldDir;
    // Estimates normal from p
    vec3 normal = estimateNormal(p, uTime);

    //fragColor = vec4(1.0, 0.0, 0.0, 1.0);
    //fragColor = vec4(estimateNormal(p), 1.0);
    vec4 purple = vec4(0.5,0.0,1.0,1.0);
    vec4 tex = texture(uTex, p.xy);
	
	rtFragColor = vec4(tex.xyz, 1.0);
	
}