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