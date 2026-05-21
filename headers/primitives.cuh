#pragma once
#include "geometry_operators.cuh"

class primitive
{
public:
	point origo;
	square_matrix<4> transform = IDENTITY4x4;
	__device__ void add_transform(const square_matrix<4>& m);
};
class sphere : public primitive
{
public:
	float radius;
	__device__ sphere();
	__device__ vector normal(const point& p) const;
};