#include "device_launch_parameters.h"
#include <iostream>
#include <fstream>
#include "canvas.cuh"
#include "corecrt_math_defines.h"
#include "ray.cuh"
#include "tests.cuh"
#include "light.cuh"

__device__ color lighting(const material& mat, const light& l, const point& p,
	const vector& direction_to_viewer, const vector& normal_at_p)
{
	color effective_color = mat.col * l.intensity;
	color ambient_contribution = effective_color * mat.ambient;

	vector direction_to_light_source = (l.position - p).normalize();
	float cos_angle_normalvec_lightvec = dot(direction_to_light_source, normal_at_p);
	
	color diffuse_contribution;
	color specular_contribution(0,0,0);
	
	float cos_eyeVec_reflVec = 0;
	if (cos_angle_normalvec_lightvec < FLT_EPSILON)
	{
		diffuse_contribution = color(0, 0, 0);
		specular_contribution = color(0, 0, 0);
	}
	else
	{
		diffuse_contribution = effective_color * mat.diffuse * cos_angle_normalvec_lightvec;
		vector reflected_direction = reflect(-direction_to_light_source, normal_at_p);
		cos_eyeVec_reflVec = dot(reflected_direction, direction_to_viewer);
	}
	if (cos_eyeVec_reflVec <= 0)
		specular_contribution = color(0, 0, 0);
	else
	{
		float factor = powf(cos_eyeVec_reflVec, mat.shininess);
		specular_contribution = l.intensity * mat.specular * factor;
	}

	color result = ambient_contribution + diffuse_contribution + specular_contribution;

	//without clamping the value highlight turns green 
	//a good subject for separate inspection of what that is happening
	result.r = fmin(fmax(result.r, 0.0f), 1.0f);
	result.g = fmin(fmax(result.g, 0.0f), 1.0f);
	result.b = fmin(fmax(result.b, 0.0f), 1.0f);


	return result;
}

__global__ void render_to_buffer(int screen_pixel_width, int screen_pixel_height, color* frame_buffer,
	primitive* s, light* l)
{
	int i = threadIdx.x + blockDim.x * blockIdx.x;
	int j = threadIdx.y + blockDim.y * blockIdx.y;
	if ((i >= screen_pixel_width) || (j >= screen_pixel_height)) return;

	primitive sph = *s;

	intersection_list<2> temporary_intersections_holder;

	//buffer is one dimensional so the way to jump to right thread for a given pixel
	//is to jump to correct row by j * screen_pixel_width and to correct pixel i in that row
	int pixel_index = j * screen_pixel_width + i;
	float u = float(i) / float(screen_pixel_width);
	float v = float(j) / float(screen_pixel_height);
	ray r(point(0,0,-6), (point(u - .5f, v - .5f, -4) - point(0, 0, -6)).normalize());
	if (r.intersects(sph, temporary_intersections_holder))
	{
		point point_of_intersection = r.position(temporary_intersections_holder.hit().intersection_length);

		frame_buffer[pixel_index] = lighting(s->mat, *l, point_of_intersection,
			-r.direction, s->normal(point_of_intersection));
	}
	else
		frame_buffer[pixel_index] = color(0, 0, 0);
}

__global__ void scene_init(primitive* s, material* m, light* l)
{
	new(s) primitive(sphere());
	s->add_transform(TRANSLATION(0,0,0));

	new(m) material(color(1, 0.2f, 1));
	new(l) light(color(1, 1, 1), point(-10, 10, -10));

	s->mat = *m;
}

__global__ void clear_scene(primitive* s, material* m, light* l)
{
	delete m;
	delete s;
	delete l;
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
	primitive* sphere_ptr;
	checkCudaErrors(cudaMalloc((void**)&sphere_ptr, sizeof(primitive)));
	//end Create a sphere

	//Create sphere material
	material* material_ptr;
	checkCudaErrors(cudaMalloc((void**)&material_ptr, sizeof(material)));
	//end material creation

	//Create light
	light* light_ptr;
	checkCudaErrors(cudaMalloc((void**)&light_ptr, sizeof(light)));
	//end light creation

	scene_init << <1, 1 >> > (sphere_ptr, material_ptr, light_ptr);
	
	blocks_threads_collection blocks_threads = define_threads_and_blocks(width, height, 8, 8);
	render_to_buffer <<<blocks_threads.blocks, blocks_threads.threads>>> (width, height, frame_buffer_ptr,
		sphere_ptr, light_ptr);

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
	clear_scene<<<1,1>>>(sphere_ptr, material_ptr, light_ptr);
	cudaFree(sphere_ptr);
	cudaFree(material_ptr);
	cudaFree(light_ptr);
	return 0;
}