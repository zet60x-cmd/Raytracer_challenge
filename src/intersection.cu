#include "intersection.cuh"

__device__ intersection::intersection(float t, const primitive& p)
{
	intersection_length = t;
	intersected_object = p;

}

__device__ void intersection_list::add(const intersection& intersec)
{
	if (size < INTERSECTION_LIST_LEN)
	{
		int index_of_insertion = 0;
				
		// find where to insert new intersection
		while (intersec.intersection_length > list[index_of_insertion].intersection_length)
			index_of_insertion++;
		
		
		// Shift every element thereafter by one pos
		for (int i = size - 1; i >= index_of_insertion; i--)
		{
			list[i + 1] = list[i];
		}

		// insert new intersection
		list[index_of_insertion] = intersec;
		size++;
	}
	else
		printf("List is full\n");
}

//For testing and debuggin
__device__ void intersection_list::print_intersections()const
{
	if (size == 0)
	{
		printf("No intersections\n");
	}
	else
	{
		printf("{");
		for (int i = 0; i < size; i++)
		{
			printf("%f\n", list[i].intersection_length);
		}
		printf("}\n");
	}
}