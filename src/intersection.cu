#include "intersection.cuh"

__device__ intersection::intersection(float t, const primitive& p)
{
	intersection_length = t;
	intersected_object = p;
}

