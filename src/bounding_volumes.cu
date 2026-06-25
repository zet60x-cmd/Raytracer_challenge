#include "bounding_volumes.cuh"

__device__ struct aabb aabb_create_default()
{
	struct aabb return_bounding_volume;
	return_bounding_volume.min = { INFINITY,INFINITY,INFINITY };
	return_bounding_volume.max = { -INFINITY,-INFINITY,-INFINITY };
	return return_bounding_volume;
}

__device__ struct aabb aabb_create(const point& min, const point& max)
{
	struct aabb bounding_volume_return;
	bounding_volume_return.min = min;
	bounding_volume_return.max = max;
	return bounding_volume_return;
}

__device__ void aabb_print(const struct aabb& aabb_to_print)
{
	printf("min: ");
	aabb_to_print.min.print_point();
	printf("max: ");
	aabb_to_print.max.print_point();
}

__device__ void aabb_add_point(struct aabb& bounding_volume, const point& point_to_add)
{
	bounding_volume.min.x = point_to_add.x < bounding_volume.min.x ? point_to_add.x : bounding_volume.min.x;
	bounding_volume.min.y = point_to_add.y < bounding_volume.min.y ? point_to_add.y : bounding_volume.min.y;
	bounding_volume.min.z = point_to_add.z < bounding_volume.min.z ? point_to_add.z : bounding_volume.min.z;
	
	bounding_volume.max.x = point_to_add.x > bounding_volume.max.x ? point_to_add.x : bounding_volume.max.x;
	bounding_volume.max.y = point_to_add.y > bounding_volume.max.y ? point_to_add.y : bounding_volume.max.y;
	bounding_volume.max.z = point_to_add.z > bounding_volume.max.z ? point_to_add.z : bounding_volume.max.z;
}

__device__ struct aabb aabb_add_boxes(const struct aabb& box1, const struct aabb& box2)
{
	struct aabb return_bounding_box;
	return_bounding_box.min.x = box1.min.x < box2.min.x ? box1.min.x : box2.min.x;
	return_bounding_box.min.y = box1.min.y < box2.min.y ? box1.min.y : box2.min.y;
	return_bounding_box.min.z = box1.min.z < box2.min.z ? box1.min.z : box2.min.z;

	return_bounding_box.max.x = box1.max.x > box2.max.x ? box1.max.x : box2.max.x;
	return_bounding_box.max.y = box1.max.y > box2.max.y ? box1.max.y : box2.max.y;
	return_bounding_box.max.z = box1.max.z > box2.max.z ? box1.max.z : box2.max.z;
	return return_bounding_box;
}

__device__ bool aabb_is_point_in_box(const struct aabb& box, const point& p)
{
	return ((box.min.x <= p.x) && (p.x <= box.max.x) &&
			(box.min.y <= p.y) && (p.y <= box.max.y) &&
			(box.min.z <= p.z) && (p.z <= box.max.z));
}

