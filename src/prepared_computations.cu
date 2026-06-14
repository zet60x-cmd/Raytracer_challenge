#include "prepared_computations.cuh"
#define MAX_REFLECTIVE_DEPTH 5

__device__ void refractive_objects_adresses_list::add(primitive* primitive_to_add_ptr)
{
	if (tail == OBJECTS_LIST_SIZE)
	{
		printf("list is full");
		return;
	}
	body[tail] = primitive_to_add_ptr;
	tail++;
	size++;
}

__device__ void refractive_objects_adresses_list::remove(int index_to_remove_primitive_at)
{
	if (size == 0)
	{
		printf("list is empty");
		return;
	}
	if (index_to_remove_primitive_at == OBJECTS_LIST_SIZE - 1)
	{
		body[index_to_remove_primitive_at] = nullptr;
		tail--;
		size--;
		return;
	}
	for (int i = index_to_remove_primitive_at; i < tail - 1; i++)
	{
		body[index_to_remove_primitive_at] = body[index_to_remove_primitive_at + 1];
	}
	tail--;
	size--;
}

__device__ int refractive_objects_adresses_list::find_element(primitive* primitive_to_find_ptr)
{
	for (int i = 0; i < size; i++)
	{
		if (body[i] == primitive_to_find_ptr)
			return i;
	}
	return INT_MAX;
}

__device__ void refractive_objects_adresses_list::print_list()
{
	printf("{");
	for (int i = 0; i < size; i++)
		printf("%p,\n", body[i]);
	printf("}\n");
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
	computations.reflected_vector = reflect(r.direction, computations.normal_vector);

	// refractive indecies	
	refractive_objects_adresses_list containers;
	intersection current_intersection;
	const primitive* current_object_ptr;
	for (int i = 0; i < all_intersections.size; i++)
	{
		current_intersection = all_intersections.list[i];
		current_object_ptr = all_intersections.list[i].objects_adress;

		// n1
		// It is not true intersection comparison but for this particular case will do
		if ((fabs(current_intersection.intersection_length - intrs.intersection_length) < MATR_EPSILON)
			&& current_intersection.intersected_object.type == intrs.intersected_object.type)
		{
			if (containers.size == 0)
				computations.n1 = 1.0f;
			else
				computations.n1 = containers.body[containers.tail - 1]->mat.refractive_index;
		}
		//broke the const promise three times
		int index_of_element_already_in_containers = containers.find_element((primitive*)current_object_ptr);
		
		if (index_of_element_already_in_containers != INT_MAX)
			containers.remove(containers.find_element((primitive*)current_object_ptr));
		else
			containers.add((primitive*)current_object_ptr);

		containers.print_list();
		// n2
		if ((fabs(current_intersection.intersection_length - intrs.intersection_length) < MATR_EPSILON)
			&& current_intersection.intersected_object.type == intrs.intersected_object.type)
		{
			if (containers.size == 0)
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
	float reflective_factor = 1;

	for(int reflective_depth = 0; reflective_depth < MAX_REFLECTIVE_DEPTH; reflective_depth++)
	{
		intersection_list intersections;

		if (!(current_ray.intersects(w, intersections)))							//ray don't hit anything in the scene
			break;

		intersection closest_hit = intersections.hit();

		prepared_computation_values computations = prepare_computation(closest_hit, current_ray, intersections);

		total_color = total_color +  reflective_factor * shade_hit(w, computations);

		if (fabs(computations.intersected_object.mat.reflective) <= MATR_EPSILON)	//object is not reflective
		{
			break;
		}

		reflective_factor *= computations.intersected_object.mat.reflective;

		current_ray = ray(computations.over_point, computations.reflected_vector);
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