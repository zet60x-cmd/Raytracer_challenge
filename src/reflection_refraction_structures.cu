#include "reflection_refraction_structures.cuh"

__device__ ray_node make_ray_node(const ray& r, float factor, int d)
{
	ray_node return_node;
	return_node.reflectance_refractance_factor = factor;
	return_node.r = r;
	return_node.depth = d;
	return return_node;
}

__device__ void refractive_objects_adresses_list::add(primitive* primitive_to_add_ptr)
{
	if (tail == OBJECTS_LIST_SIZE)
	{
		printf("refractive list is full");
		return;
	}
	body[tail] = primitive_to_add_ptr;
	tail++;
}

__device__ void refractive_objects_adresses_list::remove(int index_to_remove_primitive_at)
{
	if (tail == 0)
	{
		printf("list is empty");
		return;
	}

	for (int i = index_to_remove_primitive_at; i < tail - 1; i++)
	{
		body[i] = body[i + 1];
	}
	tail--;
	body[tail] = nullptr;
}

__device__ int refractive_objects_adresses_list::find_element(primitive* primitive_to_find_ptr)
{
	for (int i = 0; i < tail; i++)
	{
		if (body[i] == primitive_to_find_ptr)
			return i;
	}
	return INT_MAX;
}

__device__ void refractive_objects_adresses_list::print_list()
{
	printf("{");
	for (int i = 0; i < tail; i++)
		printf("%p,\n", body[i]);
	printf("}\n");
}