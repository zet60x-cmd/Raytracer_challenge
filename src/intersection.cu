#include "intersection.cuh"

__device__ intersection::intersection(float t, const primitive& p)
{
	intersection_length = t;
	intersected_object = p;
}

__device__ void intersection_list::print_intersections()const
{
	if (index == 0)
	{
		printf("No intersections");
	}
	else
	{
		printf("Intersection list{");
		for (int i = 0; i < index; i++)
		{
			printf("%f\n", list[i].intersection_length);
		}
		printf("}");
	}
}

