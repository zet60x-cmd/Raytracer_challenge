#pragma once
#include "primitives.cuh"
#include "intersection.cuh"
#include "world.cuh"

// cross promise with intersection file
// shity code structure, but it is hard to forsee what 
//requiremnts book will place on diferent data
struct intersection_list;

class ray
{
public:
	point origin;
	vector direction;

	__device__ ray();
	__device__ ray(point origin, vector direction);
	__device__ point position(float t) const;
	__device__ bool intersects(const primitive& s, intersection_list& l) const;
	__device__ bool intersects(const world& w, intersection_list& l) const;
};

__device__ ray operator*(const square_matrix<4>& m, const ray& r);