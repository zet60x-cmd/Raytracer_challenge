#pragma once
#include "primitives.cuh"
#include "assert.h"
#define DEFAULT_INTERSECTION intersection(FLT_MAX, primitive())
#define INTERSECTION_LIST_LEN 16

class intersection
{
public:
	float intersection_length;
	primitive intersected_object;
	__device__ intersection() {};
	__device__ intersection(float t, const primitive& p);
};

//header only
struct intersection_list
{
public:
	intersection list[INTERSECTION_LIST_LEN];
	int index = 0;

	__device__ void print_intersections() const;

	__device__ intersection_list()
	{
		for (int i = 0; i < INTERSECTION_LIST_LEN; i++)
		{
			list[i] = DEFAULT_INTERSECTION;
		}
	}
	__device__ void add(const intersection& i)
	{
		if (index < INTERSECTION_LIST_LEN)
		{
			list[index] = i;
			index++;
		}
		else
			printf("List is full\n");
	}
	__device__ intersection hit() const
	{
		assert(index != 0);
		float shortest_distance = FLT_MAX;
		int shortest_distance_index = INT_MAX;

		for (int i = 0; i < index; i++)
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
};