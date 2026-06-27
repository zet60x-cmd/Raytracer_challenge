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
	ray r = inverse(s.transform) * (*this);
	if (s.type == SPHERE)
	{
		vector sphere_origin_to_ray_origin = r.origin - point(0,0,0);

		float a = dot(r.direction, r.direction);
		float b = 2 * dot(r.direction, sphere_origin_to_ray_origin);
		float c = dot(sphere_origin_to_ray_origin, sphere_origin_to_ray_origin) - 1;

		float discriminant = b * b - 4 * a * c;


		if (discriminant < 0)
		{
			return false;
		}
		else
		{
			intersection inter_1 = intersection((-b - sqrt(discriminant)) / (2 * a), s, (primitive *)&s);
			intersection inter_2 = intersection((-b + sqrt(discriminant)) / (2 * a), s, (primitive *)&s);
			intersections.add(inter_1);
			intersections.add(inter_2);
			return true;
		}
	}

	else if (s.type == PLANE)
	{
		//ray r = inverse(s.transform) * (*this);
		if (fabs(r.direction.y) < MATR_EPSILON)
			return false;

		float t = -r.origin.y / r.direction.y;
		intersection intrsctn{ t, s , (primitive*) &s};
		intersections.add(intrsctn);
		return true;
	}

	else if (s.type == BOX)
	{
		//ray r = inverse(s.transform) * (*this);
		box_min_max x;
		box_min_max y;
		box_min_max z;

		x = check_axis(r.origin.x, r.direction.x);
		y = check_axis(r.origin.y, r.direction.y);
		z = check_axis(r.origin.z, r.direction.z);

		float t_min = fmax(fmax(x.min, y.min),z.min);
		float t_max = fmin(fmin(x.max, y.max), z.max);

		if (t_min > t_max)
			return false;

		intersections.add(intersection(t_min, s, (primitive*) &s));
		intersections.add(intersection(t_max, s, (primitive*) &s));
		return true;	
	}

	else if (s.type == TRIANGLE)
	{
		vector dir_cross_e2 = cross(r.direction, s.p_triangle.edge2);
		float det = dot(s.p_triangle.edge1, dir_cross_e2);
		if (fabs(det) < MATR_EPSILON)
			return false;

		float f = 1.0f / det;
		vector p1_to_origin = r.origin - s.p_triangle.p1;
		float u = f * dot(p1_to_origin, dir_cross_e2);
		if (u < 0 || u > 1)
			return false;

		vector origin_cross_e1 = cross(p1_to_origin, s.p_triangle.edge1);
		float v = f * dot(r.direction, origin_cross_e1);
		if (v < 0 || (u + v) > 1)
			return false;

		float t = f * dot(s.p_triangle.edge2, origin_cross_e1);
		intersections.add(intersection(t, s, (primitive*) &s));
		return true;
	}

	return false;				// potential bug no custome value was returned;
}

__device__ bool ray::intersects(const world& w, intersection_list& intersect_list) const
{
	bool intersect = false;

	for (size_t i = 0; i < w.tail_element_index; i++)
	{
		if (intersects(w.list[i], intersect_list))
			intersect = true;
	}
	return intersect;
}

