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
// that shit won't cut it for general matrix transformation scaling and rotation need to be
// treated differently, fix that shit, cunt.
__device__ ray operator*(const square_matrix<4>& m, const ray& r)
{
	return ray(m * r.origin, m * r.direction);
}

__device__ bool ray::intersects(const primitive& s, intersection_list& intersections) const
{
	//print_matrix(s.transform);

	ray r = inverse(s.transform) * (*this);
	vector sphere_origin_to_ray_origin = r.origin - s.p_sphere.center;

	float a = dot(r.direction, r.direction);
	float b = 2 * dot(r.direction, sphere_origin_to_ray_origin);
	float c = dot(sphere_origin_to_ray_origin, sphere_origin_to_ray_origin) - 1;

	float discriminant = b * b - 4 * a * c;


	if (discriminant < 0)
	{
		//printf("No hits, null returned.\n");
		return false;
	}
	else
	{
		intersection inter_1 = intersection((-b - sqrt(discriminant)) / (2 * a), s);
		intersection inter_2 = intersection((-b + sqrt(discriminant)) / (2 * a), s);
		intersections.add(inter_1);
		intersections.add(inter_2);
		return true;
	}
}

__device__ bool ray::intersects(const world& w, intersection_list& intersect_list) const
{
	bool intersect = false;
	for (int i = 0; i < w.tail_element_index; i++)
	{
		if (intersects(w.list[i], intersect_list))
			intersect = true;
	}
	return intersect;
}