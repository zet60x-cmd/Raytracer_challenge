//Header only
#pragma once

#include "device_launch_parameters.h"
#include "corecrt_math_defines.h"
#include "camera.cuh"

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
	right.add_transform(TRANSLATION(1.5f, .5f, -.5f) * SCALING(.5f, .5f, .5f));
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
	*cam = make_camera(512, 512, M_PI / 3);
	cam->transform = view_transforamtion(point(0, 1.5f, -5), point(0, 0, 0), vector(0, 1, 0));
}