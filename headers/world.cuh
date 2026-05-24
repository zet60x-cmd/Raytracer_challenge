//header only
#pragma once

#include "cuda_runtime.h"
#include "light.cuh"
#include "primitives.cuh"

template <int WORLD_SIZE = 2>
class world
{
public:
	light main_light;
	primitive list[WORLD_SIZE];

	__device__ world()
	{
		main_ligt = light(color(-10, -10, -10), point(1, 1, 1));
		sphere s1;
		sphere s2;
		
		s1.mat.col = color(0.8f, 1.0f, 0.6f);
		s1.mat.diffuse = 0.7f;
		s1.mat.specular = 0.2f;

		s2.add_transform(SCALING(0.5f, 0.5f, 0.5f));

		list[0] = s1;
		list[1] = s2;
	}
};