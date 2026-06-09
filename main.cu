#include "device_launch_parameters.h"
#include <iostream>
#include <fstream>
#include "canvas.cuh"
#include "corecrt_math_defines.h"
//#include "tests.cuh"
#include "prepared_computations.cuh"
#include "camera.cuh"

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

__global__ void scene_with_a_couple_of_spheres_init(world* w, camera* cam)
{
	new(w) world{ light{color(1,1,1),point{-10,10,-10}} };

	sphere sph_middle;
	sphere sph_right;
	sphere sph_left;
	plane pln_floor;

	primitive floor(pln_floor);
	floor.add_transform(ROTATION_X((float)(M_PI / 1.5)));
	floor.mat = material();
	floor.mat.col = color(1, .9f, .9f);
	floor.mat.specular = 0;
	w->world_add_primitive(floor);

	primitive middle(sph_middle);
	middle.add_transform(TRANSLATION(-.5f, 2, .5f));
	middle.mat = material();
	middle.mat.col = color(0.1f, 1, .5f);
	middle.mat.diffuse = 0.7f;
	middle.mat.specular = 0.3f;
	w->world_add_primitive(middle);

	primitive right(sph_right);
	right.add_transform(TRANSLATION(1.5f, .5f, -.5f) * SCALING(.5f,.5f,.5f));
	right.mat = material();
	right.mat.col = color(0.5f, 1, .1f);
	right.mat.diffuse = 0.7f;
	right.mat.specular = 0.3f;
	w->world_add_primitive(right);

	primitive left(sph_left);
	left.add_transform(TRANSLATION(-1.5f, .33f, -.75f) * SCALING(.33f, .33f, .33f));
	left.mat = material();
	left.mat.col = color(1, .8f, .1f);
	left.mat.diffuse = 0.7f;
	left.mat.specular = 0.3f;
	w->world_add_primitive(left);

	new(cam) camera{};
	*cam = make_camera(512,512,M_PI / 3	);
	cam->transform = view_transforamtion(point(0,1.5f,-5), point(0,0,0), vector(0,1,0));
}

__global__ void clear_scene_with_couple_of_spheres(world* w, camera* cam)
{
	delete w;
	delete cam;
}

int main()
{
	//tests << <1, 1 >> > ();
	//checkCudaErrors(cudaDeviceSynchronize());
	//return 0;

	int width = 512;
	int height = 512;
	color* frame_buffer_ptr = create_fram_buffer(width, height);
	
	//Create a sphere
	world* world_ptr;
	camera* camera_ptr;
	checkCudaErrors(cudaMalloc((void**)&world_ptr, sizeof(world)));
	checkCudaErrors(cudaMalloc((void**)&camera_ptr, sizeof(camera)));
	//end Create a sphere

	scene_with_a_couple_of_spheres_init << <1, 1 >> > (world_ptr, camera_ptr);
	
	blocks_threads_collection blocks_threads = define_threads_and_blocks(width, height, 8, 8);
	render_to_buffer <<<blocks_threads.blocks, blocks_threads.threads>>> (width, height, frame_buffer_ptr,
		world_ptr, camera_ptr);

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


	//cleanup
	image.close();
	checkCudaErrors(cudaFree(frame_buffer_ptr));
	cudaDeviceSynchronize();
	clear_scene_with_couple_of_spheres<<<1,1>>>(world_ptr, camera_ptr);
	cudaFree(world_ptr);
	cudaFree(camera_ptr);
	return 0;
}