// This is a placeholder to test that everything is set up correctly

#include <iostream>
#include <fstream>

using namespace std;

int main() {

    // Image

    const int image_width = 256;
    const int image_height = 256;

    // Render

    ofstream output;
    output.open("out.ppm");

    output << "P3\n" << image_width << ' ' << image_height << "\n255\n";

    for (int j = image_height - 1; j >= 0; --j) {
        for (int i = 0; i < image_width; ++i) {
            double r = double(i) / (double(image_width) - 1); // Casting these to doubles to avoid warnings about 4 and 6 bit overflows.
            double g = double(j) / (double(image_height) - 1);
            double b = 0.25;

            int ir = static_cast<int>(255.999 * r);
            int ig = static_cast<int>(255.999 * g);
            int ib = static_cast<int>(255.999 * b);

            output << ir << ' ' << ig << ' ' << ib << '\n';
        }
    }

    output.close();

   return 0;
}