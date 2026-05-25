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
	__device__ intersection_list<MAX_INTERSECTION_LIST_LEN> intersects(const sphere& s) const;
	
	//header only
	template <int WORLD_SIZE>
	__device__ void intersects(const world<WORLD_SIZE>& w) const
	{
		for (int i = 0; i < WORLD_SIZE; i++)
		{
			intersection_list<MAX_INTERSECTION_LIST_LEN> intr = this->intersects(*(w.list + i));

			for (int j = 0; j < intr.index; j++)
				w.intersected_lengths.add(intr.list[j]);
		}
	}
};

__device__ ray operator*(const square_matrix<4>& m, const ray& r);