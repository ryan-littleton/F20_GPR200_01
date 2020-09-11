/*
    https://raytracing.github.io/books/RayTracingInOneWeekend.html#overview
    Raytracing tutorial for Lab 1, made by Peter Shirley

    Modified by: Ryan Littleton
    Modified because: Following the Raytracing in a Weekend tutorial from the link above.
*/
#ifndef RAY_H
#define RAY_H

#include "gproVector.h"

// Ray class from tutorial https://raytracing.github.io/books/RayTracingInOneWeekend.html#overview
class ray {
public:
    ray() {}
    ray(const point3& origin, const vec3& direction)
        : orig(origin), dir(direction)
    {}

    point3 origin() const { return orig; }
    vec3 direction() const { return dir; }

    point3 at(double t) const 
    {
        return orig + t * dir;
    }

public:
    point3 orig;
    vec3 dir;
};

#endif