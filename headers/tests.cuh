#pragma once
#include "device_launch_parameters.h"
#include <cuda_runtime.h>
#include "ray.cuh"
#include "intersection.cuh"
#include "math.h"

__global__ void tests()
{
	// Normal at a point test1
		//sphere s;
		//vector n = s.normal(point(1, 0, 0));
		//n.print_vector();
	
	// Normal at a point test2
		//sphere s;
		//vector n = s.normal(point(0, 0, 1));
		//n.print_vector();

	// Normal at non-axial point
		//sphere s;
		//vector n = s.normal(point(sqrtf(3) / 3, sqrtf(3) / 3, sqrtf(3) / 3));
		//n.print_vector();

	// Normal is normal
		//sphere s;
		//vector n = s.normal(point(sqrtf(3) / 3, sqrtf(3) / 3, sqrtf(3) / 3));
		//if ((n - n.normalize()).length() <= FLT_EPSILON)
		//	printf("true");
		//else
		//	printf("false");
	
	// Normal on translated sphere
		//sphere s;
		//s.add_transform(TRANSLATION(0, 1, 0));
		//vector n = s.normal(point(0, 1.70711f, -0.70711f));
		//n.print_vector();

	// Normal on multi-transformed sphere
		//sphere s;
		//square_matrix<4> m = SCALING(1, 0.5f, 1) * ROTATION_Z(float(M_PI)/ 5);
		//s.add_transform(m);
		//vector n = s.normal(point(0, sqrtf(2) / 2, -sqrtf(2) / 2));
		//n.print_vector();
	// Ray world intersection
		//world w;
		//intersection_list intersections;
		//ray r(point(0, 0, -5), vector(0, 0, 1));
		//r.intersects(w,intersections);
		//intersections.print_intersections();
	// Prepared computations
		//ray r{ point{0,0,-5}, vector{0,0,1} };
		//primitive sph{ sphere{} };
		//intersection intrs{ 4, sph };
		//prepared_computation_values computations = prepare_computation(intrs, r);
		//computations.point_of_intersection.print_point();
		//computations.eye_view.print_vector();
		//computations.normal_view.print_vector();
	// Prepared computations is inside test
		ray r{ point{0,0,0}, vector{1,0,0} };
		primitive sph{ sphere{} };
		intersection intrs{ 1, sph };
		prepared_computation_values computations = prepare_computation(intrs, r);
		computations.point_of_intersection.print_point();
		computations.eye_view.print_vector();
		printf("%d\n", computations.is_indiside);
		computations.normal_vector.print_vector();
}