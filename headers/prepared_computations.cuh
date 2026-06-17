#pragma once
#include <cuda_runtime.h>
#include "intersection.cuh"
#include "reflection_refraction_structures.cuh"

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

__device__ bool is_shadowed(const world& wrld, const point& p);

__device__ color lighting(const material& mat, const light& l, const point& p,
	const vector& direction_to_viewer, const vector& normal_at_p, bool);

__device__ prepared_computation_values prepare_computation(const intersection& intrs, const ray& r
	,const intersection_list& all_intersections_list);

__device__ color shade_hit(const world& w, const prepared_computation_values& computations);

__device__ color color_at(const world& w, const ray& r);