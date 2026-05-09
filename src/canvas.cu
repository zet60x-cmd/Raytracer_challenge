#include "canvas.cuh"

blocks_threads_collection::blocks_threads_collection(dim3 b, dim3 t)
{
	this->blocks = b;
	this->threads = t;
}

blocks_threads_collection define_threads_and_blocks(int screen_pixel_size_x, int screen_pixel_size_y, int block_size_x, int block_size_y)
{
	dim3 blocks(screen_pixel_size_x / block_size_x + 1, screen_pixel_size_y / block_size_y + 1);
	dim3 threads_in_block(block_size_x, block_size_y);

	return blocks_threads_collection(blocks, threads_in_block);
}

color* create_fram_buffer(int screen_pixel_size_x, int screen_pixel_size_y)
{
	int number_of_pixels = screen_pixel_size_x * screen_pixel_size_y;

	color* frame_buffer_start;

	checkCudaErrors(cudaMallocManaged((void**)&frame_buffer_start, sizeof(color) * number_of_pixels));

	return frame_buffer_start;
}

