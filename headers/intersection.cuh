#pragma once
#include "primitives.cuh"
#include "ray.cuh"
#include "assert.h"
#define DEFAULT_INTERSECTION intersection(FLT_MAX, primitive())
#define INTERSECTION_LIST_LEN 16

// Cross promise with ray file
// shity code structure, but it is hard to forsee what 
//requiremnts book will place on diferent data
class ray;

class intersection
{
public:
	primitive intersected_object;
	float intersection_length;
	primitive* objects_adress = nullptr;
	__device__ intersection() {};
	__device__ intersection(float t, const primitive& p, primitive* p_ptr = nullptr);
};

struct intersection_list
{
public:
	intersection list[INTERSECTION_LIST_LEN];
	int size = 0;

	__device__ void print_intersections() const;

	//header only
	__device__ intersection_list()
	{
		for (int i = 0; i < INTERSECTION_LIST_LEN; i++)
		{
			list[i] = DEFAULT_INTERSECTION;
		}
	}

	__device__ void add(const intersection& i);

	__device__ void remove(int index_to_remove);

	//header only
	__device__ intersection hit() const
	{
		assert(size != 0);
		float shortest_distance = FLT_MAX;
		int shortest_distance_index = INT_MAX;

		for (int i = 0; i < size; i++)
		{
			if ((list[i].intersection_length < shortest_distance) &&
				list[i].intersection_length >= 0)
			{
				shortest_distance = list[i].intersection_length;
				shortest_distance_index = i;
			}
		}

		if (shortest_distance_index == INT_MAX)
		{
			//printf("No shortest distance, defaul intersection returned\n");
			return DEFAULT_INTERSECTION;
		}

		return list[shortest_distance_index];
	}

	__device__ int find_simmilar(const intersection& intrsctn_to_find) const
	{
		int index = INT_MAX;
		for (int i = 0; i < size; i++)
		{
			if ((intrsctn_to_find.intersected_object.type == list[i].intersected_object.type)
				&& (intrsctn_to_find.intersection_length == list[i].intersection_length))
			{
				index = i;
				break;
			}
		}
		return index;
	}
};


