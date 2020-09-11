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
string writeColor(color pixColor)
{
    stringstream out; //Using stringstream so this can output to the file in main
    // Write value of each color component
    out << static_cast<int>(255.999 * pixColor.x) << ' '
        << static_cast<int>(255.999 * pixColor.y) << ' '
        << static_cast<int>(255.999 * pixColor.z) << endl;

    return out.str();
}


#endif