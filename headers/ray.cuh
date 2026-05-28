#pragma once
#include "primitives.cuh"
#include "intersection.cuh"
#include "world.cuh"

class ray
{
public:
	point origin;
	vector direction;

	__device__ ray();
	__device__ ray(point origin, vector direction);
	__device__ point position(float t) const;
	__device__ intersection_list<2> intersects(const primitive& s) const;
};

__device__ ray operator*(const square_matrix<4>& m, const ray& r);