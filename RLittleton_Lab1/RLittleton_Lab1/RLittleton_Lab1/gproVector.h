/*
   Copyright 2020 Daniel S. Buckstein

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

	   http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

/*
	gproVector.h
	Interface for vectors. Sets an example for C and C++ compatible headers.

	Modified by: Ryan Littleton
	Modified because: Expanding functionality and typedefs for color
*/
#include <iostream>
#include <math.h>

#ifndef _GPRO_VECTOR_H_
#define _GPRO_VECTOR_H_


#ifdef __cplusplus
// DB: link C++ symbols as if they are C where possible
using namespace std;

extern "C" {
#else	// !__cplusplus
// DB: forward declare C types... why?
//	-> in C++ you would instantiate one of these like so: 
//		vec3 someVector;
//	-> in C you do it like this: 
//		union vec3 someVector;
//	-> this forward declaration makes the first way possible in both languages!
typedef union vec3 vec3;
#endif	// __cplusplus


// DB: declare shorthand types

typedef double double3[3];		// 3 doubles form the basis of a double vector
typedef double* doublev;			// generic double vector (pointer)
typedef double const* doublekv;	// generic constant double vector (pointer)


// DB: declare 3D vector
//	-> why union? all data in the union uses the same address... in this case: 
//		'v' and 'struct...' share the same address
//	-> this means you can have multiple names for the same stuff!

// vec3
//	A 3D vector data structure.
//		member v: array (pointer) version of data
//		members x, y, z: named components of vector
union vec3
{
	double3 v;
	struct { double x, y, z; };

#ifdef __cplusplus
	// DB: in C++ we can have convenient member functions
	//	-> e.g. constructors, operators
	explicit vec3();	// default ctor
	explicit vec3(double const xc, double const yc = 0.0f, double const zc = 0.0f);	// init ctor w one or more doubles
	explicit vec3(double3 const vc);	// copy ctor w generic array of doubles
	vec3(vec3 const& rh);	// copy ctor

	vec3& operator =(vec3 const& rh);	// assignment operator (copy other to this)

	vec3& operator +=(vec3 const& rh);	// addition assignment operator (add other to this)

	vec3 const operator +(vec3 const& rh) const;	// addition operator (get sum of this and another)

    // Not sure why these functions are here and not inlined in the .inl, but I don't want to accidentally break the tutorial so leaving them here for now
    // Modified version of *= operator from tutorial https://raytracing.github.io/books/RayTracingInOneWeekend.html#overview
    vec3& operator*=(const double t) {
        x *= t;
        y *= t;
        z *= t;
        return *this;
    }

    // /= operator from tutorial https://raytracing.github.io/books/RayTracingInOneWeekend.html#overview
    vec3& operator/=(const double t) {
        return *this *= 1 / t;
    }

    // length from tutorial https://raytracing.github.io/books/RayTracingInOneWeekend.html#overview
    double length() const {
        return sqrt(lengthSquared());
    }

    // Modified version of length_squared from tutorial https://raytracing.github.io/books/RayTracingInOneWeekend.html#overview
    double lengthSquared() const {
        return x * x + y * y + z * z;
    }


#endif	// __cplusplus
};

// Ryan Littleton
#ifdef __cplusplus
// DB: Functions from tutorial here

// Modified version of << operator from tutorial https://raytracing.github.io/books/RayTracingInOneWeekend.html#overview
inline ostream& operator<<(ostream& out, const vec3& rh) {
    return out << rh.x << ' ' << rh.y << ' ' << rh.z;
}

// Modified version of - operator from tutorial https://raytracing.github.io/books/RayTracingInOneWeekend.html#overview
inline vec3 operator-(const vec3& u, const vec3& v) {
    return vec3(u.x - v.x, u.y - v.y, u.z - v.z);
}

// Modified version of * operators from tutorial https://raytracing.github.io/books/RayTracingInOneWeekend.html#overview
inline vec3 operator*(double mult, const vec3& rh) {
    return vec3(mult * rh.x, mult * rh.y, mult * rh.z);
}

// Modified version of / operator from tutorial https://raytracing.github.io/books/RayTracingInOneWeekend.html#overview
inline vec3 operator/(vec3 v, double t) {
    return (1 / t) * v;
}

// Modified version of dot from tutorial https://raytracing.github.io/books/RayTracingInOneWeekend.html#overview
inline double dot(const vec3& u, const vec3& v) {
    return u.x * v.x
        + u.y * v.y
        + u.z * v.z;
}

// Modified version of cross from tutorial https://raytracing.github.io/books/RayTracingInOneWeekend.html#overview
inline vec3 cross(const vec3& u, const vec3& v) {
    return vec3(u.y * v.z - u.z * v.y,
        u.z * v.x - u.x * v.z,
        u.x * v.y - u.y * v.x);
}

// Modified version of cross from tutorial https://raytracing.github.io/books/RayTracingInOneWeekend.html#overview
inline vec3 unit_vector(vec3 v) {
    return v / v.length();
}
#endif	// __cplusplus

// DB: declare C functions (all equivalents of above C++ functions are here)
//	-> return pointers so you can chain operations (they just take pointers)

doublev vec3default(double3 v_out);	// default init
doublev vec3init(double3 v_out, double const xc, double const yc, double const zc);	// init w doubles
doublev vec3copy(double3 v_out, double3 const v_rh);	// init w array of doubles (same as assign and both copy ctors)

doublev vec3add(double3 v_lh_sum, double3 const v_rh);	// add other to lh vector

doublev vec3sum(double3 v_sum, double3 const v_lh, double3 const v_rh);	// get sum of lh and rh vector

// Ryan Littleton
#ifdef __cplusplus
// DB: adding color / point3 aliases
using point3 = vec3; // Point in 3D space
using color = vec3; // RGB color value
#endif	// __cplusplus


#ifdef __cplusplus
// DB: end C linkage for C++ symbols
}
#endif	// __cplusplus


// DB: include inline definitions for this interface
#include "_inl/gproVector.inl"


#endif	// !_GPRO_VECTOR_H_