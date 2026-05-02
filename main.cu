#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <iostream>
#include "geometry_operators.cuh"
#include <fstream>

#define checkCudaErrors(val) check_cuda( (val), #val, __FILE__, __LINE__ )
void check_cuda(cudaError_t result, char const* const func, const char* const file, int const line) {
	if (result) {
		std::cerr << "CUDA error = " << static_cast<unsigned int>(result) << " at " <<
			file << ":" << line << " '" << func << "' \n";
		// Make sure we call CUDA Device Reset before exiting
		cudaDeviceReset();
		exit(99);
	}
}

//class canvas
//{
//public:
//	int screen_pixel_size_x;
//	int screen_pixel_size_y;
//
//	canvas()
//	{
//		screen_pixel_size_x = 0;
//		screen_pixel_size_y = 0;
//	}
//
//	canvas(int screen_pixel_size_x, int screen_pixel_size_y)
//	{
//		this->screen_pixel_size_x = screen_pixel_size_x;
//		this->screen_pixel_size_y = screen_pixel_size_y;
//	}
//};

__global__ void render_to_buffer(int screen_pixel_widht, int screen_pixel_height, color* frame_buffer)
{
	int i = threadIdx.x + blockDim.x * blockIdx.x;
	int j = threadIdx.y + blockDim.y * blockIdx.y;

	if ((i >= screen_pixel_widht) || (j >= screen_pixel_height)) return;

	//buffer is one dimensional so the way to jump to right thread for a given pixel
	//is to jump to correct row by j * screen_pixel_width and to correct pixel i in that row
	int pixel_index = j * screen_pixel_widht + i;
	float u = float(i) / float(screen_pixel_widht);
	float v = float(j) / float(screen_pixel_height);
	frame_buffer[pixel_index] = color(u, v, 0.2f);
}

int main()
{

	int screen_pixel_size_x = 1024;
	int screen_pixel_size_y = 512;

	int number_of_pixels = screen_pixel_size_x * screen_pixel_size_y;

	color* frame_buffer_start;

	checkCudaErrors(cudaMallocManaged((void**)&frame_buffer_start, sizeof(color) * number_of_pixels));

	int threads_in_block_in_x = 8;
	int threads_in_block_in_y = 8;

	dim3 blocks(screen_pixel_size_x / threads_in_block_in_x + 1, screen_pixel_size_y / threads_in_block_in_y + 1);
	dim3 threads_in_block(threads_in_block_in_x, threads_in_block_in_y);

	render_to_buffer <<<blocks, threads_in_block>>> (screen_pixel_size_x, screen_pixel_size_y, frame_buffer_start);

	checkCudaErrors(cudaGetLastError());
	checkCudaErrors(cudaDeviceSynchronize());

	std::ofstream image("output.ppm");

	image << "P3" << std::endl;
	image << screen_pixel_size_x << " " << screen_pixel_size_y << std::endl;
	image << "255" << std::endl;

	for (int j = screen_pixel_size_y - 1; j >= 0; j--)
	{
		for (int i = 0; i < screen_pixel_size_x; i++)
		{
			int pixel_index = j * screen_pixel_size_x + i;
			int ir = int(255.99 * frame_buffer_start[pixel_index].r);
			int ig = int(255.99 * frame_buffer_start[pixel_index].g);
			int ib = int(255.99 * frame_buffer_start[pixel_index].b);
			image << ir << " " << ib << " " << ig << std::endl;
		}
	}

	image.close();
	checkCudaErrors(cudaFree(frame_buffer_start));
	return 0;
}