#include "device_launch_parameters.h"
#include <iostream>
#include <fstream>
#include "canvas.cuh"
#include "corecrt_math_defines.h"
#include "ray.cuh"
#include "tests.cuh"

__global__ void render_to_buffer(int screen_pixel_width, int screen_pixel_height, color* frame_buffer, sphere* s)
{
	int i = threadIdx.x + blockDim.x * blockIdx.x;
	int j = threadIdx.y + blockDim.y * blockIdx.y;
	if ((i >= screen_pixel_width) || (j >= screen_pixel_height)) return;

	sphere sph = *s;

	//print_matrix(s->transform);

	//buffer is one dimensional so the way to jump to right thread for a given pixel
	//is to jump to correct row by j * screen_pixel_width and to correct pixel i in that row
	int pixel_index = j * screen_pixel_width + i;
	float u = float(i) / float(screen_pixel_width);
	float v = float(j) / float(screen_pixel_height);
	ray r(point(0,0,-6), (point(u - .5f, v - .5f, -4) - point(0, 0, -6)).normalize());
	if (r.intersects(sph).hit().intersection_length < FLT_MAX)
	{
		frame_buffer[pixel_index] = color(1, 0, 0);
	}
	else
		frame_buffer[pixel_index] = color(0, 0, 0);
}

__global__ void test()
{
	bool inv = is_invertible(TRANSLATION(200, 1, 0) * IDENTITY4x4);
	printf("%d", inv);
}

__global__ void scene_init(sphere* s)
{
	new(s) sphere();
	s->add_transform(TRANSLATION(0,0,0));
}

__global__ void clear_scene(sphere* s)
{
	print_matrix(s->transform);
	delete s;
}

int main()
{
	tests << <1, 1 >> > ();
	checkCudaErrors(cudaDeviceSynchronize());
	return 0;

	int width = 512;
	int height = 512;
	color* frame_buffer_ptr = create_fram_buffer(width, height);
	
	//Create a sphere
	sphere* sphere_ptr;
	checkCudaErrors(cudaMalloc((void**)&sphere_ptr, sizeof(sphere)));
	scene_init << <1, 1 >> > (sphere_ptr);
	//end Create a sphere

	blocks_threads_collection blocks_threads = define_threads_and_blocks(width, height, 8, 8);
	render_to_buffer <<<blocks_threads.blocks, blocks_threads.threads>>> (width, height, frame_buffer_ptr, sphere_ptr);

	checkCudaErrors(cudaGetLastError());
	checkCudaErrors(cudaDeviceSynchronize());
	std::ofstream image("output.ppm");

	image << "P3" << std::endl;
	image << width << " " << height << std::endl;
	image << "255" << std::endl;

	for (int j = height - 1; j >= 0; j--)
	{
		for (int i = 0; i < width; i++)
		{
			int pixel_index = j * width + i;
			int ir = int(255.99 * frame_buffer_ptr[pixel_index].r);
			int ig = int(255.99 * frame_buffer_ptr[pixel_index].g);
			int ib = int(255.99 * frame_buffer_ptr[pixel_index].b);
			image << ir << " " << ig << " " << ib << std::endl;
		}
	}

	image.close();
	checkCudaErrors(cudaFree(frame_buffer_ptr));
	cudaDeviceSynchronize();
	clear_scene<<<1,1>>>(sphere_ptr);
	cudaFree(sphere_ptr);
	return 0;
}