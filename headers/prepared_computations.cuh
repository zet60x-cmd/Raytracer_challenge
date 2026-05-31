#pragma once
#include <cuda_runtime.h>
#include "intersection.cuh"


struct prepared_computation_values
{
	primitive intersected_object;
	point point_of_intersection;
	vector eye_view;
	vector normal_vector;
	float intersection_length;
	bool is_indiside;
};

__device__ color lighting(const material& mat, const light& l, const point& p,
	const vector& direction_to_viewer, const vector& normal_at_p);

__device__ prepared_computation_values prepare_computation(const intersection& intrs, const ray& r);

__device__ color shade_hit(const world& w, const prepared_computation_values& computations);

__device__ color color_at(const world& w, const ray& r);