#pragma once
#include "cuda_runtime.h"
#include "cuda_error.cuh"
#include "geometry_operators.cuh"

struct blocks_threads_collection
{
public:
	dim3 blocks;
	dim3 threads;

	blocks_threads_collection(dim3 b, dim3 t);
};

blocks_threads_collection define_threads_and_blocks(int screen_pixel_size_x, int screen_pixel_size_y, int block_size_x, int block_size_y);

color* create_fram_buffer(int screen_pixel_size_x, int screen_pixel_size_y);