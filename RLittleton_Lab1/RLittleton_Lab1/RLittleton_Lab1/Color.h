/*
    https://raytracing.github.io/books/RayTracingInOneWeekend.html#overview
    Raytracing tutorial for Lab 1, made by Peter Shirley

    Modified by: Ryan Littleton
    Modified because: Following the Raytracing in a Weekend tutorial from the link above.
*/

#ifndef COLOR_H // I've never come across ifndef before, assuming it means if not defined then do the code
#define COLOR_H

#include "gproVector.h"
#include <iostream>
#include <string>
#include <sstream>
using namespace std;

// Modified version of write_color from tutorial https://raytracing.github.io/books/RayTracingInOneWeekend.html#overview
string writeColor(color pixColor, int samplesPerPixel)
{
    stringstream out; //Using stringstream so this can output to the file in main

    double r = pixColor.x;
    double g = pixColor.y;
    double b = pixColor.z;

    // Divide the color by the number of samples.
    double scale = 1.0 / samplesPerPixel;
    r *= scale;
    g *= scale;
    b *= scale;

    // Write value of each color component
    out << static_cast<int>(256 * clamp(r, 0.0, 0.999)) << ' '
        << static_cast<int>(256 * clamp(g, 0.0, 0.999)) << ' '
        << static_cast<int>(256 * clamp(b, 0.0, 0.999)) << endl;

    return out.str();
}


#endif