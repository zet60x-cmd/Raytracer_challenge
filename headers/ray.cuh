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
	__device__ bool intersects(const primitive& s, intersection_list<2>& l) const;
	
	//header only
	//template <int WORLD_SIZE>
	//__device__ intersection_list<MAX_INTERSECTION_LIST_LEN> intersects(const world<WORLD_SIZE>& wor) const
	//{
	//	intersection_list<MAX_INTERSECTION_LIST_LEN> return_list;
	//	for (int i = 0; i < WORLD_SIZE; i++)
	//	{
	//		
	//	}
	//}
};

__device__ ray operator*(const square_matrix<4>& m, const ray& r);