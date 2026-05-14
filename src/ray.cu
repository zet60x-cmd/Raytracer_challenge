#include "ray.cuh"

__device__ ray::ray()
{
	this->origin = point(0, 0, 0);
	this->direction = vector(0, 0, 0);
}

__device__ ray::ray(point origin, vector direction)
{
	this->origin = origin;
	this->direction = direction;
}

__device__ point ray::position(float t) const
{
	return (t * direction + origin);
}

__device__ intersection_list<2> ray::intersects(const sphere& s) const
{
	intersection_list<2> intersections;
	vector sphere_origin_to_ray_origin = origin - s.origo;

	float a = dot(direction, direction);
	float b = 2 * dot(direction, sphere_origin_to_ray_origin);
	float c = dot(sphere_origin_to_ray_origin, sphere_origin_to_ray_origin) - 1;

	float discriminant = b * b - 4 * a * c;

	if (discriminant < 0)
	{
		printf("No hits, null returned.");
		printf("%f", discriminant);
		return intersections;
	}

	intersection inter_1 = intersection((-b - sqrt(discriminant)) / (2 * a), s);
	intersection inter_2 = intersection((-b + sqrt(discriminant)) / (2 * a), s);
	intersections.add(inter_1);
	intersections.add(inter_2);
	return intersections;
}