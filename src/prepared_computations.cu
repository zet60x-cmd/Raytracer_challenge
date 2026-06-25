#include "prepared_computations.cuh"
#define MAX_ITERATIVE_DEPTH 5


__device__ float schlick(const prepared_computation_values& computations)
{
	float cosine = dot(computations.eye_view, computations.normal_vector);
	if (computations.n1 > computations.n2)
	{
		float n = computations.n1 / computations.n2;
		float sine_2_transmitted_angle = n * n * (1.0f - cosine * cosine);
		if (sine_2_transmitted_angle > 1.0f)
			return 1.0f;

		cosine = sqrtf(1.0f - sine_2_transmitted_angle);
	}
	float r0 = (computations.n1 - computations.n2) / (computations.n1 + computations.n2);
	r0 *= r0;
	float x = (1 - cosine);
	x = x * x * x * x * x;
	return r0 + (1 - r0) * x;
}

__device__ bool is_shadowed(const world& wrld, const point& p)
{
	vector world_to_light_vec = wrld.main_light.position - p;

	float distance = world_to_light_vec.length();
	
	vector dir = world_to_light_vec.normalize();

	ray r(p, dir);

	intersection_list intr_ls;

	r.intersects(wrld, intr_ls);

	intersection h = intr_ls.hit();

	if (MATR_EPSILON <= distance - h.intersection_length)
		return true;
	return false;
}

__device__ color lighting(const material& mat, const light& l, const point& p,
	const vector& direction_to_viewer, const vector& normal_at_p, bool in_shadow)
{
	color effective_color = mat.col * l.intensity;
	
	vector direction_to_light_source = (l.position - p).normalize();
	
	color ambient_contribution = effective_color * mat.ambient;

	float cos_angle_normalvec_lightvec = dot(direction_to_light_source, normal_at_p);

	color diffuse_contribution(0, 0, 0);
	color specular_contribution(0, 0, 0);

	float cos_eyeVec_reflVec = 0;
	if (cos_angle_normalvec_lightvec < FLT_EPSILON || in_shadow)
	{
		diffuse_contribution = color(0, 0, 0);
		specular_contribution = color(0, 0, 0);
	}
	else
	{
		diffuse_contribution = effective_color * mat.diffuse * cos_angle_normalvec_lightvec;
		vector reflected_direction = reflect(-direction_to_light_source, normal_at_p);
		cos_eyeVec_reflVec = dot(reflected_direction, direction_to_viewer);
	}
	if (cos_eyeVec_reflVec <= FLT_EPSILON || in_shadow)
		specular_contribution = color(0, 0, 0);
	else
	{
			float factor = powf(cos_eyeVec_reflVec, mat.shininess);
		specular_contribution = l.intensity * mat.specular * factor;
	}

	color result = ambient_contribution + diffuse_contribution + specular_contribution;

	return result;
}

__device__ prepared_computation_values prepare_computation(const intersection& intrs, const ray& r
	, const intersection_list& all_intersections)
{
	prepared_computation_values computations;

	computations.is_indiside = false;
	computations.intersection_length = intrs.intersection_length;
	computations.intersected_object = intrs.intersected_object;
	computations.point_of_intersection = r.position(computations.intersection_length);
	computations.eye_view = -r.direction;
	computations.normal_vector = computations.intersected_object.normal(computations.point_of_intersection);

	if (dot(computations.normal_vector, computations.eye_view) < 0)
	{
		computations.is_indiside = true;
		computations.normal_vector = -computations.normal_vector;
	}
	// for some reason stepping approx 0.005f away from surface gives decent results anything less
	// solves acne for smaller spheres and for non rotated spheres in the test scene but not for scaled rotated spheres
	computations.over_point = computations.point_of_intersection + 0.005f * computations.normal_vector;
	computations.under_point = computations.point_of_intersection - 0.005f * computations.normal_vector;
	computations.reflected_vector = reflect(r.direction, computations.normal_vector);

	// refractive indecies	
	intersection current_intersection = DEFAULT_INTERSECTION;
	primitive* current_object_ptr = nullptr;
	refractive_objects_adresses_list containers;
	for (int i = 0; i < all_intersections.size; i++)
	{
		current_intersection = all_intersections.list[i];
		current_object_ptr = all_intersections.list[i].objects_adress;
		// n1
		// It is not true intersection comparison but for this particular case will do
		if ((fabs(current_intersection.intersection_length - intrs.intersection_length) < MATR_EPSILON)
			&& current_object_ptr == intrs.objects_adress)
		{
			if (containers.tail == 0)
				computations.n1 = 1.0f;
			else
				computations.n1 = containers.body[containers.tail - 1]->mat.refractive_index;
		}
		//broke the const promise three times
		int index_of_element_already_in_containers = containers.find_element((primitive*)current_object_ptr);
		
		if (index_of_element_already_in_containers != INT_MAX)
			containers.remove(index_of_element_already_in_containers);
		else
			containers.add((primitive*)current_object_ptr);

		// n2
		if ((fabs(current_intersection.intersection_length - intrs.intersection_length) < MATR_EPSILON)
			&& current_object_ptr == intrs.objects_adress)
		{
			if (containers.tail == 0)
				computations.n2 = 1.0f;
			else
				computations.n2 = containers.body[containers.tail - 1]->mat.refractive_index;
			break;
		}
	}

	return computations;
}

__device__ color shade_hit(const world& w, const prepared_computation_values& computations)
{
	bool shadowed = is_shadowed(w, computations.over_point);
	color surface_color = lighting(computations.intersected_object.mat, w.main_light, computations.point_of_intersection,
		computations.eye_view, computations.normal_vector, shadowed);
	return surface_color;
}

__device__ color color_at(const world& w, const ray& r)
{
	color total_color{ 0,0,0 };
	ray current_ray = r;

	const int stack_size = 1 << MAX_ITERATIVE_DEPTH;
	ray_stack<stack_size> stack;
	ray_node current_ray_node = make_ray_node(current_ray, 1, MAX_ITERATIVE_DEPTH);
	stack.push(current_ray_node);

	while (!(stack.is_empty()))
	{
		//stack.print_addresses();
		current_ray_node = stack.top();
		current_ray = current_ray_node.r;
		stack.pop();

		intersection_list intersections;
		if (!(current_ray.intersects(w, intersections)))
			continue;
		if (current_ray_node.depth <= 0)
			continue;

		intersection closest_hit = intersections.hit();
		prepared_computation_values computations = prepare_computation(closest_hit, current_ray, intersections);
		total_color = total_color + current_ray_node.reflectance_refractance_factor * shade_hit(w, computations);

		// reflections/refractions
		material current_material = computations.intersected_object.mat;
		float reflected_schlick = 1.0f;
		float refracted_schlick = 1.0f;

		if ((current_material.transparency > MATR_EPSILON) && (current_material.reflective > MATR_EPSILON))
		{
			reflected_schlick = schlick(computations);
			refracted_schlick = 1.0f - reflected_schlick;
		}


		//reflections
		if (fabs(computations.intersected_object.mat.reflective) > MATR_EPSILON)	//object is reflective
		{
			ray reflected_ray = ray(computations.over_point, computations.reflected_vector);
			ray_node reflected_node = make_ray_node(reflected_ray,
				current_ray_node.reflectance_refractance_factor * computations.intersected_object.mat.reflective
				* reflected_schlick,
				current_ray_node.depth - 1);
			stack.push(reflected_node);
		}

		//refractions
		float n_ratio = computations.n1 / computations.n2;
		float cosine_inbound_angle = dot(computations.eye_view, computations.normal_vector);
		float sine_2_transmitted_angle = n_ratio * n_ratio * (1 - cosine_inbound_angle * cosine_inbound_angle);
		if (sine_2_transmitted_angle <= 1)								//object is refractive
		{
			float cosine_transmitted_angle = sqrtf(1.0f - sine_2_transmitted_angle);
			vector transmitted_direction = computations.normal_vector * (n_ratio * cosine_inbound_angle
				- cosine_transmitted_angle) - computations.eye_view * n_ratio;
			ray refracted_ray = ray(computations.under_point, transmitted_direction);
			ray_node refracted_node = make_ray_node(refracted_ray,
				current_ray_node.reflectance_refractance_factor * computations.intersected_object.mat.transparency
				* refracted_schlick,
				current_ray_node.depth - 1);
			stack.push(refracted_node);
		}
	}

	//Make colors stay in bounds 0 to 1

	// Clamping
	total_color.r = fmin(fmax(total_color.r, 0.0f), 1.0f);
	total_color.g = fmin(fmax(total_color.g, 0.0f), 1.0f);
	total_color.b = fmin(fmax(total_color.b, 0.0f), 1.0f);

	//Reinhard with exposure
	//float exposure = 4.0f;
	//total_color.r *= exposure / (exposure * total_color.r + 1.0f);
	//total_color.g *= exposure / (exposure * total_color.g + 1.0f);
	//total_color.b *= exposure / (exposure * total_color.b + 1.0f);

	

	return total_color;
}