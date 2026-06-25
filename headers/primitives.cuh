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

struct box_min_max
{
	float min = FLT_MIN;
	float max = FLT_MAX;
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
	__device__ box() {};
	__device__ vector normal(const point& p, square_matrix<4>) const;
};

__device__ box_min_max check_axis(float origin, float direction);


struct triangle
{
	point p1;
	point p2;
	point p3;
	vector edge1;
	vector edge2;
	vector norm;
	__device__ triangle(const point& p1, const point& p2, const point& p3);
	__device__ vector normal(const point& p ,square_matrix<4> transform) const;
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
	__device__ primitive(const triangle& t);
	__device__ vector normal(const point& p);
	__device__ void add_transform(const square_matrix<4>& m);
	
	union
	{
		sphere p_sphere;
		plane p_plane;
		box p_box;
		triangle p_triangle;
	};
};

