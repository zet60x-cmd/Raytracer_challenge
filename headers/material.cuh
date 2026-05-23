//header only
#pragma once
#include "geometry_operators.cuh"

class material
{
public:
	color col;
	float ambient;
	float diffuse;
	float specular;
	float shininess;

	__device__ material() {};

	__device__ material(const color& col, float ambient = 0.1f,
		float diffuse = 0.9f, float specular = 0.9f, float shininess = 32.0f)
	{
		this->col = col;
		this->ambient = ambient;
		this->diffuse = diffuse;
		this->specular = specular;
		this->shininess = shininess;
	}
};