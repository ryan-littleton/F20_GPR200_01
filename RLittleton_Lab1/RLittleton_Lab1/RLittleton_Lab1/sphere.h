/*
    https://raytracing.github.io/books/RayTracingInOneWeekend.html#overview
    Raytracing tutorial for Lab 1, made by Peter Shirley

    Modified by: Ryan Littleton
    Modified because: Removing autos and changing include, lengthSquared
*/

#ifndef SPHERE_H
#define SPHERE_H

#include "hittable.h"
#include "gproVector.h"

class sphere : public hittable {
public:
    sphere() {}
    sphere(point3 cen, double r) : center(cen), radius(r) {};

    virtual bool hit(
        const ray& r, double tmin, double tmax, hit_record& rec) const override;

public:
    point3 center = vec3();
    double radius = 0.0;
};

bool sphere::hit(const ray& r, double t_min, double t_max, hit_record& rec) const {
    vec3 oc = r.origin() - center;
    double a = r.direction().lengthSquared();
    double half_b = dot(oc, r.direction());
    double c = oc.lengthSquared() - radius * radius;
    double discriminant = half_b * half_b - a * c;

    if (discriminant > 0) {
        double root = sqrt(discriminant);

        double temp = (-half_b - root) / a;
        if (temp < t_max && temp > t_min) {
            rec.t = temp;
            rec.p = r.at(rec.t);
            rec.normal = (rec.p - center) / radius;
            vec3 outward_normal = (rec.p - center) / radius;
            rec.set_face_normal(r, outward_normal);
            return true;
        }

        temp = (-half_b + root) / a;
        if (temp < t_max && temp > t_min) {
            rec.t = temp;
            rec.p = r.at(rec.t);
            rec.normal = (rec.p - center) / radius;
            vec3 outward_normal = (rec.p - center) / radius;
            rec.set_face_normal(r, outward_normal);
            return true;
        }
    }

    return false;
}


#endif
