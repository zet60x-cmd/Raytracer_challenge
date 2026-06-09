//header only
#pragma once

#include "cuda_runtime.h"
#include "primitives.cuh"
#include "light.cuh"

#define WORLD_SIZE 100

class world
{
public:
	light main_light;
	primitive list[WORLD_SIZE];
	int tail_element_index = 0;

	//default world two sphere one insided another and a point light
	__device__ world()
	{
		main_light = light(color(1, 1, 1), point(-10, 10, -10));
		primitive s1{sphere{}};
		primitive s2{sphere{}};
		
		s1.mat.col = color(0.8f, 1.0f, 0.6f);
		s1.mat.diffuse = 0.7f;
		s1.mat.specular = 0.2f;

		s2.add_transform(SCALING(0.5f, 0.5f, 0.5f));

		list[0] = s1;
		list[1] = s2;
		tail_element_index += 2;
	}

	// empty world
	__device__ world(const light& main_light)
	{
		this->main_light = main_light;
	}

	__device__ void world_add_primitive(const primitive& primitive_to_add)
	{
		if (tail_element_index < WORLD_SIZE)
		{
			list[tail_element_index] = primitive_to_add;
			tail_element_index++;
		}
		else
			printf("World is full.");
	}
};