#pragma once
#include "geometry_operators.cuh"
struct aabb
{
	point min;
	point max;
};

__device__ struct aabb aabb_create_default();	
__device__ struct aabb aabb_create(const point& min,const point& max);
__device__ void aabb_print(const struct aabb& aabb_to_print);
__device__ void aabb_add_point(struct aabb& bounding_volume, const point& point_to_add);
__device__ struct aabb aabb_add_boxes(const struct aabb& box1, const struct aabb& box2);
__device__ bool aabb_is_point_in_box(const struct aabb& box, const point& p);
