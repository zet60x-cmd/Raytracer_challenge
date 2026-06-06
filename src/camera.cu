#include "camera.cuh"

__device__ square_matrix<4> view_transforamtion(const point& from, const point& to, const vector& up)
{
	vector forward = (to - from).normalize();
	vector up_normalized = up.normalize();
	vector left = cross(forward, up_normalized);
	vector true_up = -cross(left, forward);

	square_matrix<4> orientation
	{
		left.x ,	left.y,		left.z,		0,
		true_up.x,	true_up.y,	true_up.z,	0,
		-forward.x,	-forward.y,	-forward.z,	0,
		0,			0,			0,			1
	};

	return orientation * TRANSLATION(-from.x, -from.y, -from.z);
}

__device__ camera make_camera(int hsize, int vsize, float fov)
{
	camera return_camera;

	// Set values
	return_camera.canvas_horizontal_pixel_size = hsize;
	return_camera.canvas_vertical_pixel_size = vsize;
	return_camera.feild_of_view = fov;

	//Calculate pixel size
	float half_view = tanf(return_camera.feild_of_view / float(2) );
	float aspect_ratio = hsize / vsize;

	//orientation of fov is dedcided base on the bigger dimension
	if (aspect_ratio >= 1)
	{
		return_camera.half_width = half_view;
		return_camera.half_height = half_view / aspect_ratio;
	}
	else
	{
		return_camera.half_width = half_view * aspect_ratio;
		return_camera.half_height = half_view;
	}
	return_camera.pixelsize = return_camera.half_width * 2 / return_camera.canvas_horizontal_pixel_size;
	return return_camera;
}

__device__ ray ray_to_pixel(const camera& cam, int pixel_index_x, int pixel_index_y)
{
	float x_offset = (pixel_index_x + 0.5) * cam.pixelsize;
	float y_offset = (pixel_index_y + 0.5) * cam.pixelsize;

	float world_x = cam.half_width - x_offset;
	float world_y = cam.half_height - y_offset;

	square_matrix<4> inverse_transform = inverse(cam.transform);
	point pixel_world_position = inverse_transform * point(world_x, world_y, -1);
	point origin = inverse_transform * point(0, 0, 0);
	vector direction = (pixel_world_position - origin).normalize();

	return ray(origin, direction);
}