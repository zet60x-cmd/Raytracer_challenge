#include "device_launch_parameters.h"
#include <iostream>
#include <fstream>
#include "canvas.cuh"

__global__ void render_to_buffer(int screen_pixel_width, int screen_pixel_height, color* frame_buffer)
{
	int i = threadIdx.x + blockDim.x * blockIdx.x;
	int j = threadIdx.y + blockDim.y * blockIdx.y;

	if ((i >= screen_pixel_width) || (j >= screen_pixel_height)) return;

	//buffer is one dimensional so the way to jump to right thread for a given pixel
	//is to jump to correct row by j * screen_pixel_width and to correct pixel i in that row
	int pixel_index = j * screen_pixel_width + i;
	float u = float(i) / float(screen_pixel_width);
	float v = float(j) / float(screen_pixel_height);
	frame_buffer[pixel_index] = color(u, v, 0.2f);
}

__global__ void test()
{
	square_matrix<4> mat({
		1, 2, 3, 4,
		2, 4, 4, 2,
		8, 6, 4, 1,
		0, 0, 0, 1
		});
	square_matrix<4> mat1 = transpose(mat);
	mat1.print_matrix();
}


int main()
{
	//int width = 1024;
	//int height = 512;
	//color* frame_buffer_ptr = create_fram_buffer(width, height);

	//blocks_threads_collection blocks_threads = define_threads_and_blocks(width, height, 8, 8);

	//render_to_buffer <<<blocks_threads.blocks, blocks_threads.threads>>> (width, height, frame_buffer_ptr);

	//checkCudaErrors(cudaGetLastError());
	//checkCudaErrors(cudaDeviceSynchronize());

	//std::ofstream image("output.ppm");

	//image << "P3" << std::endl;
	//image << width << " " << height << std::endl;
	//image << "255" << std::endl;

	//for (int j = height - 1; j >= 0; j--)
	//{
	//	for (int i = 0; i < width; i++)
	//	{
	//		int pixel_index = j * width + i;
	//		int ir = int(255.99 * frame_buffer_ptr[pixel_index].r);
	//		int ig = int(255.99 * frame_buffer_ptr[pixel_index].g);
	//		int ib = int(255.99 * frame_buffer_ptr[pixel_index].b);
	//		image << ir << " " << ig << " " << ib << std::endl;
	//	}
	//}

	//image.close();
	//checkCudaErrors(cudaFree(frame_buffer_ptr));
	test << <1, 1 >> > ();
	cudaDeviceSynchronize();
	return 0;
}