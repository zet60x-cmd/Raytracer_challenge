#include "geometry_operators.cuh"

__device__ point::point()
{
	this->x = 0.0f;
	this->y = 0.0f;
	this->z = 0.0f;
	this->w = 1.0f;

}

__device__ point::point(float x, float y, float z)
{
	this->x = x;
	this->y = y;
	this->z = z;
	this->w = 1.0f;

}

__device__ vector::vector(float x, float y, float z)
{
	this->x = x;
	this->y = y;
	this->z = z;
	this->w = 0.0f;
}

__device__ bool is_point(const point& p)
{
	return (p.w == 1.0f);
}

__device__ bool is_vector(const point& p)
{
	return (p.w == 0.0f);
}

__device__ vector operator+(const vector& p1, const vector& p2)
{
	return vector(p1.x + p2.x,
				  p1.y + p2.y,
				  p1.z + p2.z);
}

__device__ point operator+(const vector& v, const point& p)
{
	return point(v.x + p.x,
				 v.y + p.y,
				 v.z + p.z);
}

__device__ point operator+(const point& v, const vector& p)
{
	return point(v.x + p.x,
				 v.y + p.y,
				 v.z + p.z);
}

__device__ vector operator-(const point& p, const vector& v)
{
	return vector(p.x - v.x,
				  p.y - v.y,
				  p.z - v.z);
}