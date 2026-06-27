#include <filesystem>
#include <iostream>
#include <fstream>
#include "canvas.cuh"
#include "prepared_computations.cuh"
#include "Scenes.cuh"
#include "tests.cuh"
#include "Parser.cuh"


__global__ void render_to_buffer(int screen_pixel_width, int screen_pixel_height, color* frame_buffer,
	world* w, camera* cam)
{
	int i = threadIdx.x + blockDim.x * blockIdx.x;
	int j = threadIdx.y + blockDim.y * blockIdx.y;
	if ((i >= screen_pixel_width) || (j >= screen_pixel_height)) return;

	//buffer is one dimensional so the way to jump to right thread for a given pixel
	//is to jump to correct row by j * screen_pixel_width and to correct pixel i in that row
	int pixel_index = j * screen_pixel_width + i;
	ray r = ray_to_pixel(*cam, i, j);
	frame_buffer[pixel_index] = color_at(*w, r);
}

__global__ void clear_scene(world* w, camera* cam)
{
	delete w;
	delete cam;
}

int main()
{
	//tests << <1, 1 >> > ();
	//checkCudaErrors(cudaDeviceSynchronize());
	//return 0;


	// Geometry parser
	Mesh_host mesh;
	std::string path = "dragon.obj";
	parser_read(mesh, path);
	std::vector<triangle> geometry = parser_mesh_to_triangles(mesh);
	//return 0;

	int width = WIDTH;
	int height = HEIGHT;
	color* frame_buffer_ptr = create_fram_buffer(width, height);
	
	//Create a scene
	world* world_ptr;
	camera* camera_ptr;
	triangle* loaded_geometry;
	checkCudaErrors(cudaMalloc((void**)&world_ptr, sizeof(world)));
	checkCudaErrors(cudaMalloc((void**)&camera_ptr, sizeof(camera)));
	checkCudaErrors(cudaMalloc((void**)&loaded_geometry, geometry.size() * sizeof(triangle)));
	checkCudaErrors(cudaMemcpy(loaded_geometry, geometry.data(), geometry.size() * sizeof(triangle), cudaMemcpyHostToDevice));


	scene_with_a_couple_of_spheres_init <<<1, 1>> > (world_ptr, camera_ptr, geometry.size());
	
	printf("%d", geometry.size());
	load_mesh<<<6, 512 >> >(world_ptr, loaded_geometry, geometry.size());
	checkCudaErrors(cudaGetLastError());
	checkCudaErrors(cudaDeviceSynchronize());
	

	blocks_threads_collection blocks_threads = define_threads_and_blocks(width, height, 8, 8);
	render_to_buffer <<<blocks_threads.blocks, blocks_threads.threads>>> (width, height, frame_buffer_ptr,
		world_ptr, camera_ptr);

	checkCudaErrors(cudaGetLastError());
	checkCudaErrors(cudaDeviceSynchronize());
	std::ofstream image("output_dragon.ppm");

	image << "P3" << std::endl;
	image << width << " " << height << std::endl;
	image << "255" << std::endl;

	for (int j = height - 1; j >= 0; j--)
	{
		for (int i = 0; i < width; i++)
		{
			size_t pixel_index = j * width + i;
			int ir = int(255.99 * frame_buffer_ptr[pixel_index].r);
			int ig = int(255.99 * frame_buffer_ptr[pixel_index].g);
			int ib = int(255.99 * frame_buffer_ptr[pixel_index].b);
			image << ir << " " << ig << " " << ib << std::endl;
		}
	}

	//cleanup
	image.close();
	checkCudaErrors(cudaFree(frame_buffer_ptr));
	cudaDeviceSynchronize();
	clear_scene<<<1,1>>>(world_ptr, camera_ptr);
	cudaFree(world_ptr);
	cudaFree(camera_ptr);
	return 0;
}