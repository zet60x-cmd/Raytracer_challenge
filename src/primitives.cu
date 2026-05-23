#include "primitives.cuh"

__device__ void primitive::add_transform(const square_matrix<4>& m)
{
	transform = m * transform;
}

__device__ sphere::sphere()
{
	origo = point(0, 0, 0);
	radius = 1.0f;

}

__device__ vector sphere::normal(const point& p) const
{
	point point_in_object_space = inverse(transform) * p;
	vector normal_in_object_space =  (point_in_object_space - point(0, 0, 0));
	vector normal_in_world_space = (transpose(inverse(transform)) * normal_in_object_space);
	return normal_in_world_space.normalize();
}
