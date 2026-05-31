#include "prepared_computations.cuh"

__device__ color lighting(const material& mat, const light& l, const point& p,
	const vector& direction_to_viewer, const vector& normal_at_p)
{
	color effective_color = mat.col * l.intensity;
	color ambient_contribution = effective_color * mat.ambient;

	vector direction_to_light_source = (l.position - p).normalize();
	float cos_angle_normalvec_lightvec = dot(direction_to_light_source, normal_at_p);

	color diffuse_contribution;
	color specular_contribution(0, 0, 0);

	float cos_eyeVec_reflVec = 0;
	if (cos_angle_normalvec_lightvec < FLT_EPSILON)
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
	if (cos_eyeVec_reflVec <= 0)
		specular_contribution = color(0, 0, 0);
	else
	{
		float factor = powf(cos_eyeVec_reflVec, mat.shininess);
		specular_contribution = l.intensity * mat.specular * factor;
	}

	color result = ambient_contribution + diffuse_contribution + specular_contribution;

	//without clamping the value highlight turns green 
	//a good subject for separate inspection of what that is happening
	result.r = fmin(fmax(result.r, 0.0f), 1.0f);
	result.g = fmin(fmax(result.g, 0.0f), 1.0f);
	result.b = fmin(fmax(result.b, 0.0f), 1.0f);


	return result;
}

__device__ prepared_computation_values prepare_computation(const intersection& intrs, const ray& r)
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

	return computations;
}

__device__ color shade_hit(const world& w, const prepared_computation_values& computations)
{
	return lighting(computations.intersected_object.mat, w.main_light, computations.point_of_intersection,
		computations.eye_view, computations.normal_vector);
}

__device__ color color_at(const world& w, const ray& r)
{
	intersection_list intersections;

	if (!(r.intersects(w, intersections)))								//ray don't hit anything in the scene
		return color(0, 0, 0);

	intersection closest_hit = intersections.hit();

	prepared_computation_values computations = prepare_computation(closest_hit, r);
	
	return shade_hit(w, computations);
}