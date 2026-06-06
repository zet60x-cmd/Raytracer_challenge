#pragma once

#include "ray.cuh"

//transformation matrix, moves world around view
__device__ square_matrix<4> view_transforamtion(const point& from, const point& to, const vector& up);

struct camera
{
	square_matrix<4> transform = IDENTITY4x4;
	int canvas_horizontal_pixel_size = 0;
	int canvas_vertical_pixel_size = 0;
	float half_width = 0.0f;
	float half_height = 0.0f;
	float feild_of_view = 0;
	float pixelsize = 0;
};

__device__ camera make_camera(int hsize, int vsize, float fov);

__device__ ray ray_to_pixel(const camera &cam, int pixel_index_x, int pixel_index_y);