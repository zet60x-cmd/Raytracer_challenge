#pragma once
#include <vector>
#include "primitives.cuh"
#include "intersection.cuh"


class ray
{
public:
	point origin;
	vector direction;

	__device__ ray();
	__device__ ray(point origin, vector direction);
	__device__ point position(float t) const;
	__device__ intersection_list<2> intersects(const sphere& s) const;
};