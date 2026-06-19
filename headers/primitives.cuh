#pragma once
#include "geometry_operators.cuh"
#include "material.cuh"

enum PrimitiveType
{
	SPHERE,
	BOX,
	TRIANGLE,
	PLANE,
	FREE
};

struct sphere
{
	point center;
	__device__ sphere() {};
	__device__ vector normal(const point& p, square_matrix<4>) const;
};

struct plane
{
	__device__ plane() {};
	__device__ vector normal(const point& p, square_matrix<4>) const;
};

struct box
{
	point min;
	point max;
	__device__ box() {};
	__device__ vector normal(const point& p, square_matrix<4>) const;
};

struct primitive
{
	PrimitiveType type = FREE;
	square_matrix<4> transform = IDENTITY4x4;
	material mat;

	__device__ primitive();
	__device__ primitive(const sphere& s);
	__device__ primitive(const plane& p);
	__device__ primitive(const box& b);
	__device__ vector normal(const point& p);
	__device__ void add_transform(const square_matrix<4>& m);
	
	union
	{
		sphere p_sphere;
		plane p_plane;
		box p_box;
	};
};
