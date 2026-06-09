#include "primitives.cuh"

__device__ void primitive::add_transform(const square_matrix<4>& m)
{
	transform = m * transform;
}

__device__ primitive::primitive() {};

__device__ primitive::primitive(const sphere& s)
{
	p_sphere = s;
	type = SPHERE;
}

__device__ primitive::primitive(const plane& p)
{
	p_plane = p;
	type = PLANE;
}

__device__ sphere::sphere()
{
	center = point(0, 0, 0);
	radius = 1.0f;
}

__device__ vector sphere::normal(const point& p, square_matrix<4> transform) const
{
	point point_in_object_space = inverse(transform) * p;
	vector normal_in_object_space =  (point_in_object_space - point(0, 0, 0));
	vector normal_in_world_space = (transpose(inverse(transform)) * normal_in_object_space);
	return normal_in_world_space.normalize();
}

__device__ vector plane::normal(const point& p, square_matrix<4> transform) const
{
	point point_in_object_space = inverse(transform) * p;
	vector normal_in_object_space(0, 1, 0);
	vector normal_in_world_space = (transpose(inverse(transform)) * normal_in_object_space);
	return normal_in_world_space.normalize();
}

__device__ vector primitive::normal(const point& p)
{
	if (type == SPHERE)
	{
		return p_sphere.normal(p, transform);
	}
	if (type == PLANE)
	{
		return p_plane.normal(p, transform);
	}
}