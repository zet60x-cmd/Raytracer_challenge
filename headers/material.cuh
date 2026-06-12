//header only
#pragma once
#include "geometry_operators.cuh"

class material
{
public:
	color col{1,1,1};
	float ambient = 0.1f;
	float diffuse = 0.9f;
	float specular = .9f;
	float shininess = 200;
	float reflective = 0.0f;

	__device__ material() {};

	__device__ material(const color& col, float ambient,
		float diffuse, float specular, float shininess, float reflective)
	{
		this->col = col;
		this->ambient = ambient;
		this->diffuse = diffuse;
		this->specular = specular;
		this->shininess = shininess;
		this->reflective = reflective;
	}
};