#pragma once
#include "geometry_operators.cuh"

class primitive
{
public:
	point origo;
};
class sphere : public primitive
{
public:
	float radius;

	__device__ sphere();
};