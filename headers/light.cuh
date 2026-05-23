//header only
#pragma once
#include "geometry_operators.cuh"

class light
{
public:
	color intensity;
	point position;

	__device__ light(const color& col, const point& pos)
	{
		intensity = col;
		position = pos;
	}
};

