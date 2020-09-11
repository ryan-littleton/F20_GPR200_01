/*
Author: Ryan Littleton
Class : GPR-200-01
Assignment : Lab 1
*/
/*
    https://raytracing.github.io/books/RayTracingInOneWeekend.html#overview
    Raytracing tutorial for Lab 1, made by Peter Shirley

    Modified by: Ryan Littleton
    Modified because: Following the Raytracing in a Weekend tutorial from the link above.
*/

#include "rtweekend.h"
#include "Color.h" // My other programming classes all had us use uppercase for file names, should I swap to lowercase to match yours going forward?
#include "hittable_list.h"
#include "sphere.h"

#include <iostream>
#include <fstream>

using namespace std;

// modified rayColor from tutorial https://raytracing.github.io/books/RayTracingInOneWeekend.html#overview 
// Colors the scene with rays, checking hittables 
color rayColor(const ray& r, const hittable& world) {
    hit_record rec;
    if (world.hit(r, 0, infinity, rec)) {
        return 0.5 * (rec.normal + color(1, 1, 1));
    }
    vec3 unit_direction = unit_vector(r.direction());
    double t = 0.5 * (unit_direction.y + 1.0);
    return (1.0 - t) * color(1.0, 1.0, 1.0) + t * color(0.5, 0.7, 1.0);
}


int main() {

    // Resolution, Aspect from tutorial https://raytracing.github.io/books/RayTracingInOneWeekend.html#overview 
    const double ASPECT_RATIO = 16.0 / 9.0;
    const int IMAGE_WIDTH = 400;
    const int IMAGE_HEIGHT = static_cast<int>(IMAGE_WIDTH / ASPECT_RATIO);

    // World hittables from tutorial https://raytracing.github.io/books/RayTracingInOneWeekend.html#overview
    hittable_list world;
    world.add(make_shared<sphere>(point3(0, 0, -1), 0.5));
    world.add(make_shared<sphere>(point3(0, -100.5, -1), 100));

    // Camera from tutorial https://raytracing.github.io/books/RayTracingInOneWeekend.html#overview 
    double viewportHeight = 2.0;
    double viewportWidth = ASPECT_RATIO * viewportHeight;
    double focalLength = 1.0;
    
    point3 origin = point3(0, 0, 0);
    vec3 horizontal = vec3(viewportWidth, 0, 0);
    vec3 vertical = vec3(0, viewportHeight, 0);
    vec3 lowerLeftCorner = origin - horizontal / 2 - vertical / 2 - vec3(0, 0, focalLength);

    // Initialize output file
    ofstream output; 
    output.open("out.ppm");

    // Render to PPM file
    output << "P3" << endl << IMAGE_WIDTH << ' ' << IMAGE_HEIGHT << endl << "255" << endl;

    // Modified Loop from Peter Shirley, https://raytracing.github.io/books/RayTracingInOneWeekend.html#overview
    for (int j = IMAGE_HEIGHT - 1; j >= 0; --j) {
        cerr << "\rScanlines remaining: " << j << ' ' << flush; // progress indicator
        for (int i = 0; i < IMAGE_WIDTH; ++i) {
            double u = double(i) / (double(IMAGE_WIDTH) - 1);
            double v = double(j) / (double(IMAGE_HEIGHT) - 1);
            ray r(origin, lowerLeftCorner + u * horizontal + v * vertical - origin);
            color pixelColor = rayColor(r, world);
            output << writeColor(pixelColor);
        }
    }

    /* Second version of loop
    for (int j = IMAGE_HEIGHT - 1; j >= 0; --j) {
        cerr << "\rScanlines remaining: " << j << ' ' << flush;
        for (int i = 0; i < IMAGE_WIDTH; ++i) {
            color pixelColor(double(i) / (double(IMAGE_WIDTH) - 1), double(j) / (double(IMAGE_HEIGHT) - 1), 0.25);
            output << writeColor(pixelColor);
        }
    }
    */

    /* Old version of above loop
    for (int j = image_height - 1; j >= 0; --j) {
        cerr << "\rScanlines remaining: " << j << ' ' << flush;
        for (int i = 0; i < image_width; ++i) {
            double r = double(i) / (double(image_width) - 1); // Casting these to doubles to avoid warnings about 4 and 6 bit overflows.
            double g = double(j) / (double(image_height) - 1);
            double b = 0.25;

            int ir = static_cast<int>(255.999 * r);
            int ig = static_cast<int>(255.999 * g);
            int ib = static_cast<int>(255.999 * b);

            output << ir << ' ' << ig << ' ' << ib << endl;
        }
    }
    */

    // Done to error stream, close output file
    cerr << "\nDone.\n";
    output.close();

}