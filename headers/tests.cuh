#pragma once
#include "device_launch_parameters.h"
#include "ray.cuh"
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
		//ray r{ point{0,0,0}, vector{1,0,0} };
		//primitive sph{ sphere{} };
		//intersection intrs{ 1, sph };
		//prepared_computation_values computations = prepare_computation(intrs, r);
		//computations.point_of_intersection.print_point();
		//computations.eye_view.print_vector();
		//printf("%d\n", computations.is_indiside);
		//computations.normal_vector.print_vector();
	// Shade hit function
	
	//Reminder adjust the return of hit for intersection list!!!!!!!!
		
		//a)
		//world w{};
		//intersection_list intrs_list;
		//ray r{ point{0,0,-5}, vector{0,0,1} };
		//r.intersects(w, intrs_list);
		//primitive sph{ intrs_list.list[0].intersected_object };
		//intersection intrs{4, sph};
		//prepared_computation_values computations = prepare_computation(intrs, r);
		//shade_hit(w, computations).print_color();
		
		//b)
		//world w{};
		//w.main_light = light{ color(1,1,1), point(0,.25f,0) };
		//ray r{ point{0,0,0}, vector{0,0,1} };
		//intersection_list intrs_list;
		//r.intersects(w, intrs_list);
		//intrs_list.print_intersections();
		//primitive sph{ intrs_list.hit().intersected_object};
		//intersection intrs{ 0.5f, sph };
		//prepared_computation_values computations = prepare_computation(intrs, r);
		//shade_hit(w, computations).print_color();

	// Color at function
		
		//a) ray misses
		//world w;
		//ray r{ point{0,0,-5}, vector{0,1,0} };
		//color c = color_at(w, r);
		//c.print_color();
		
		//b) ray hits
		//world w;
		//ray r{ point{0,0,-5}, vector{0,0,1} };
		//color c = color_at(w, r);
		//c.print_color();

	// Transformation matrix
		
		//a) No	change
		//point from{ 0,0,0 };
		//point to{ 0,0,-1 };
		//vector up{ 0,1,0 };
		//square_matrix<4> tranformation = view_transforamtion(from, to, up);
		//print_matrix(tranformation);

		//b) Looking back
		//point from{ 0,0,0 };
		//point to{ 0,0,1 };
		//vector up{ 0,1,0 };
		//square_matrix<4> tranformation = view_transforamtion(from, to, up);
		//print_matrix(tranformation);

		//c) Moving the world
		//point from{ 0,0,8 };
		//point to{ 0,0,0 };
		//vector up{ 0,1,0 };
		//square_matrix<4> tranformation = view_transforamtion(from, to, up);
		//print_matrix(tranformation);

		//d) Arbitrary transformation
		//point from{ 1,3,2 };
		//point to{ 4,-2,8 };
		//vector up{ 1,1,0 };
		//square_matrix<4> tranformation = view_transforamtion(from, to, up);
		//print_matrix(tranformation);

	//Plane normal transformed
		//plane pln_floor;
		//primitive floor(pln_floor);
		//intersection_list intrsctn_lst;
		//floor.add_transform(ROTATION_X((float)(M_PI / 2)));
		//ray r{ point(0,0,-5), vector(0,0,1)};
		//printf("%d", r.intersects(floor, intrsctn_lst));

	// Reflection of vector against a plane
		//plane p{};
		//intersection_list intrsctn_lst;
		//ray r{ point(0, 1, -1), vector{0, -sqrtf(2) / 2, sqrtf(2) / 2} };
		//r.intersects(p, intrsctn_lst);
		//intersection intrsctn = intrsctn_lst.hit();
		//prepared_computation_values computations = prepare_computation(intrsctn, r);
		//computations.reflected_vector.print_vector();

	// Ray striking a non-reflective material
		//world w;
		//intersection_list intrsctn_lst;
		//ray r{ point{0,0,0}, vector{0,0,1} };
		//r.intersects(w, intrsctn_lst);
		//intersection intrsctn = intrsctn_lst.hit();
		//intrsctn.intersected_object.mat.ambient = 1;
		//prepared_computation_values computations = prepare_computation(intrsctn, r);
		//color c = reflected_color(w, computations);
		//c.print_color();

		// Ray striking a reflective material
		//world w;
		//plane p;
		//primitive pln{p};
		//pln.mat.reflective = .5f;
		//pln.add_transform(TRANSLATION(0, -1, 0));
		//w.world_add_primitive(pln);
		//intersection_list intrsctn_lst;
		//ray r{ point{0,0,-3}, vector{0, -sqrtf(2) / 2, sqrtf(2) / 2} };
		//r.intersects(w, intrsctn_lst);
		//intersection intrsctn = intrsctn_lst.hit();
		//intrsctn.intersected_object.mat.ambient = 1;
		//prepared_computation_values computations = prepare_computation(intrsctn, r);
		//color c = reflected_color(w, computations);
		//c.print_color();

	// n1 n2 test
		sphere sph;
		primitive glass_sphere(sph);
		glass_sphere.mat.refractive_index = 1.5f;
		glass_sphere.mat.transparency = 1.0f;

		primitive sphA;
		sphA.add_transform(SCALING(2, 2, 2));
		sphA.mat.refractive_index = 1.5f;
		
		primitive sphB = glass_sphere;
		sphB.add_transform(TRANSLATION(0,0,-0.25f));
		sphB.mat.refractive_index = 2.0f;

		primitive sphC = glass_sphere;
		sphC.add_transform(TRANSLATION(0, 0, 0.25f));
		sphC.mat.refractive_index = 2.5f;

		ray r{ point{0,0,-4},vector{0,0,1} };
		intersection_list xs;
		xs.add(intersection{ 2, sphA , &sphA});
		xs.add(intersection{ 2.75f, sphB , &sphB});
		xs.add(intersection{ 3.25f, sphC , &sphC});
		xs.add(intersection{ 4.75f, sphB , &sphB});
		xs.add(intersection{ 5.25f, sphC , &sphC});
		xs.add(intersection{ 6, sphA , &sphA});
		prepared_computation_values computations = prepare_computation(xs.list[5], r, xs);
		printf("n1: %f, n2: %f \n", computations.n1, computations.n2);






}