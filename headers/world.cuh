//header only
#pragma once

#include "cuda_runtime.h"
#include "light.cuh"
#include "intersection.cuh"

#define DEFAULT_WORLD_SIZE 2
#define MAX_WORLS_SIZE 100

template <int WORLD_SIZE>
class world
{
public:
	light main_light;
	primitive list[WORLD_SIZE  + DEFAULT_WORLD_SIZE];

	__device__ world()
	{
		main_light = light(color(-10, -10, -10), point(1, 1, 1));
		primitive s1{sphere{}};
		primitive s2{sphere{}};
		
		s1.mat.col = color(0.8f, 1.0f, 0.6f);
		s1.mat.diffuse = 0.7f;
		s1.mat.specular = 0.2f;

		s2.add_transform(SCALING(0.5f, 0.5f, 0.5f));

		list[0] = s1;
		list[1] = s2;
	}
};