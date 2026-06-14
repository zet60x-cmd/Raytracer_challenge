#pragma once
#include <cuda_runtime.h>
#include "intersection.cuh"
#define OBJECTS_LIST_SIZE 32

struct prepared_computation_values
{
	primitive intersected_object;
	point point_of_intersection;
	point over_point;
	vector eye_view;
	vector normal_vector;
	vector reflected_vector;
	float intersection_length;
	float n1;
	float n2;
	bool is_indiside;
};

// soul purpose of this thing is aiding in finding correct refractive indecies between mediums
struct refractive_objects_adresses_list
{
	primitive* body[OBJECTS_LIST_SIZE];
	int tail = 0;
	int size = 0;

	__device__ refractive_objects_adresses_list() {};
	__device__ void add(primitive* primitive_to_add_ptr);
	__device__ void remove(int index_to_remove_primitive_at);
	__device__ int find_element(primitive* primitive_to_find_ptr);
	__device__ void print_list();
};

__device__ bool is_shadowed(const world& wrld, const point& p);

__device__ color lighting(const material& mat, const light& l, const point& p,
	const vector& direction_to_viewer, const vector& normal_at_p, bool);

__device__ prepared_computation_values prepare_computation(const intersection& intrs, const ray& r
	,const intersection_list& all_intersections_list);

__device__ color shade_hit(const world& w, const prepared_computation_values& computations);

__device__ color color_at(const world& w, const ray& r);