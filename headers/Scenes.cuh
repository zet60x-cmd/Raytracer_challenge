//Header only
#pragma once

#include "device_launch_parameters.h"
#include "corecrt_math_defines.h"
#include "camera.cuh"

#define WIDTH 200
#define HEIGHT 200

__global__ void load_mesh(world* w,triangle* loaded_data, size_t geometry_size)
{
	int tid = threadIdx.x + blockIdx.x * blockDim.x;
	//printf("%d", ((tid + loaded_data) != nullptr));
	if (((loaded_data + threadIdx.x) != nullptr) && ((tid) < geometry_size) )
	{
		
		primitive curr_primitive = primitive(loaded_data[tid]);
		curr_primitive.add_transform(ROTATION_Y((float)M_PI * 2 / 3) * TRANSLATION(1,0,0));
		w->list[tid + 1] = (curr_primitive);
	}
}

__global__ void scene_with_a_couple_of_spheres_init(world* w, camera* cam, size_t loaded_geometry_offset)
{
	new(w) world{ light{color(1,1,1),point{-10,10,-10}} };

	//sphere sph_middle;
	//sphere sph_right;
	//sphere sph_left;
	//sphere sph_front;
	plane pln_floor;
	//box bx;
	//triangle tr{ point(0, 1, 0), point(-1, 0, 0), point(1, 0, 0) };

	//primitive trngl(tr);
	//trngl.add_transform(TRANSLATION(-.5f, .5, -4.0f) * ROTATION_Y((float) M_PI /3) * ROTATION_X((float)M_PI / 5));
	//trngl.mat = material();
	//trngl.mat.col = color(.2f, .5f, .5f);
	//trngl.mat.diffuse = 0.7f;


	primitive floor(pln_floor);
	floor.mat = material();
	floor.mat.col = color(.2f, .2f, .2f);
	floor.mat.specular = 0;
	floor.mat.reflective = .5f;

	//primitive middle(sph_middle);
	//middle.add_transform(TRANSLATION(-.5f, 1, .5f));
	//middle.mat = material();
	//middle.mat.reflective = .5f;
	//middle.mat.col = color(0.1f, 1, .5f);
	//middle.mat.diffuse = 0.7f;
	//middle.mat.specular = 0.3f;

	//primitive cube(bx);
	//cube.add_transform(SCALING(.4f, .4f, .4f) * ROTATION_Y((float) (M_PI / 4)) * TRANSLATION(2.f, 1, -7.f));
	//cube.mat = material();
	//cube.mat.col = color(0.5f, 0.5f, .5f);
	//cube.mat.diffuse = 0.7f;
	//cube.mat.specular = 0.3f;
	//cube.mat.transparency = .5f;
	//cube.mat.refractive_index = 1.3f;

	//primitive right(sph_right);
	//right.add_transform(TRANSLATION(1.5f, .5f, -.5f) * SCALING(.5f, .5f, .5f));
	//right.mat = material();
	//right.mat.col = color(0.5f, 1, .1f);
	//right.mat.diffuse = 0.7f;
	//right.mat.specular = 0.3f;

	//primitive left(sph_left);
	//left.add_transform(TRANSLATION(-1.5f, .33f, -.75f) * SCALING(.33f, .33f, .33f));
	//left.mat = material();
	//left.mat.col = color(1, .8f, .1f);
	//left.mat.diffuse = 0.7f;
	//left.mat.specular = 0.3f;

	//primitive front(sph_front);
	//front.add_transform(TRANSLATION(0.0f, 1, -3) * SCALING(.5f, .5f, .5f));
	//front.mat = material();
	//front.mat.diffuse = 0.0f;
	//front.mat.specular = 0.3f;
	//front.mat.transparency = .7f;
	//front.mat.refractive_index = 1.5f;

	//w->world_add_primitive(middle);
	//w->world_add_primitive(front);
	//w->world_add_primitive(left);
	//w->world_add_primitive(right);
	//w->world_add_primitive(cube);
	w->world_add_primitive(floor);
	w->tail_element_index += loaded_geometry_offset;
	//w->world_add_primitive(trngl);

	//w->list = loaded_data;

	
	new(cam) camera{};
	*cam = make_camera(HEIGHT, WIDTH, M_PI / 3);
	cam->transform = view_transforamtion(point(-1.0f, .5f, -7), point(0, 0, 0), vector(0, 1, 0));
}