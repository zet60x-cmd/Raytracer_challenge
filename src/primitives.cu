#include "primitives.cuh"

__device__ void primitive::add_transform(const square_matrix<4>& m)
{
	transform = m * transform;
}

__device__ primitive::primitive() {};

__device__ primitive::primitive(const sphere& s)
{
	type = SPHERE;
}

__device__ primitive::primitive(const plane& p)
{
	type = PLANE;
}

__device__ primitive::primitive(const box& b)
{
	type = BOX;
}

__device__ box_min_max check_axis(float origin, float direction)
{
	float tmin_numerator = (-1 - origin);
	float tmax_numerator = (1 - origin);

	box_min_max ret_value;

	if (fabs(direction) >= MATR_EPSILON)
	{
		ret_value.min = tmin_numerator / direction;
		ret_value.max = tmax_numerator / direction;
	}

	else
	{
		ret_value.min = (tmin_numerator > 0 ? FLT_MAX : -FLT_MAX);
		ret_value.max = (tmax_numerator > 0 ? FLT_MAX : -FLT_MAX);
	}

	if (ret_value.max < ret_value.min)
	{
		float temp = ret_value.max;
		ret_value.max = ret_value.min;
		ret_value.min = temp;
	}
	return ret_value;
}

__device__ vector sphere::normal(const point& p, square_matrix<4> transform) const
{
	point point_in_object_space = inverse(transform) * p;
	vector normal_in_object_space =  (point_in_object_space - point(0, 0, 0));
	vector normal_in_world_space = (transpose(inverse(transform)) * normal_in_object_space);
	return normal_in_world_space.normalize();
}

__device__ vector plane::normal(const point& p, square_matrix<4> transform) const
{
	point point_in_object_space = inverse(transform) * p;
	vector normal_in_object_space(0, 1, 0);
	vector normal_in_world_space = (transpose(inverse(transform)) * normal_in_object_space);
	return normal_in_world_space.normalize();
}

__device__ vector box::normal(const point& p, square_matrix<4> transform) const
{
	point point_in_object_space = inverse(transform) * p;
	vector normal_in_object_space{0,0,0};

	float x = fabs(point_in_object_space.x);
	float y = fabs(point_in_object_space.y);
	float z = fabs(point_in_object_space.z);

	if (x >= y && x >= z)
		normal_in_object_space = vector((point_in_object_space.x > 0 ? 1.0f : -1.0f), 0, 0);
	else if (y >= z && y >= x)
		normal_in_object_space = vector(0, (point_in_object_space.y > 0 ? 1.0f : -1.0f), 0);
	else if(z >= y && z >= x)
		normal_in_object_space = vector(0, 0, (point_in_object_space.z > 0 ? 1.0f : -1.0f));
	vector normal_in_world_space = (transpose(inverse(transform)) * normal_in_object_space);
	return normal_in_world_space.normalize();
}

__device__ vector primitive::normal(const point& p)
{
	if (type == SPHERE)
	{
		return p_sphere.normal(p, transform);
	}
	else if (type == PLANE)
	{
		return p_plane.normal(p, transform);
	}
	else if (type == BOX)
	{
		return p_box.normal(p, transform);
	}
	
	return vector(0, 0, 0);		//bug here, didn't return a custom value
}