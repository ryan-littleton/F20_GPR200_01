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


#include <iostream>
#include <fstream>

using namespace std;

int main() {

    // Resolution
    const int image_width = 256;
    const int image_height = 256;

    // Initialize output file
    ofstream output; 
    output.open("out.ppm");

    // Render
    output << "P3" << endl << image_width << ' ' << image_height << endl << "255" << endl;

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

    // Done to error stream, close output file
    cerr << "\nDone.\n";
    output.close();

}