#pragma once
#include <cuda_runtime.h>
#include "ray.cuh"
#define OBJECTS_LIST_SIZE 16

struct ray_node
{
	ray r;
	float reflectance_refractance_factor = 1;
	int depth;
};

__device__ ray_node make_ray_node(const ray& r, float factor, int d);

//header only
template <int SIZE>
struct ray_stack
{
	ray_node body[SIZE];
	int head = 0;

	__device__ bool is_full()
	{
		return (head >= SIZE);
	}

	__device__ void push(ray_node& node)
	{
		if (is_full())
		{
			printf("stack is full");
			return;
		}
		body[head] = node;
		head++;
	}
	__device__ void pop()
	{
		if (!(is_empty()))
		{
			head--;
			return;
		}
		printf("stack is empty");
	}
	__device__ ray_node top()
	{
		return body[head - 1];
	}
	__device__ bool is_empty()
	{
		return (head <= 0);
	}
	__device__ void print_addresses()
	{
		printf("{");
		for (int i = 0; i < head; i++)
		{
			printf("%p\n", &(body[i]));
		}
		printf("}\n");
	}
};

// soul purpose of this thing is aiding in finding correct refractive indecies between mediums
struct refractive_objects_adresses_list
{
	primitive* body[OBJECTS_LIST_SIZE];
	int tail = 0;

	__device__ refractive_objects_adresses_list() {};
	__device__ void add(primitive* primitive_to_add_ptr);
	__device__ void remove(int index_to_remove_primitive_at);
	__device__ int find_element(primitive* primitive_to_find_ptr);
	__device__ void print_list();
};