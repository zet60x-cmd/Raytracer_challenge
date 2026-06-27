#include "geometry_operators.cuh"

__device__ __device__ color::color()
{
	this->r = 0.0f;
	this->g = 0.0f;
	this->b = 0.0f;
}

__device__ __device__ color::color(float r, float g, float b)
{
	this->r = r;
	this->g = g;
	this->b = b;
}

__device__ __device__ void color::print_color() const
{
	printf("%f, %f, %f \n", r, g, b);
}

__device__ __device__ color operator+(const color& c1, const color& c2)
{
	return color
	(
		c1.r + c2.r,
		c1.g + c2.g,
		c1.b + c2.b
	);
}

__device__ __device__ color operator-(const color& c1, const color& c2)
{
	return color
	(
		c1.r - c2.r,
		c1.g - c2.g,
		c1.b - c2.b
	);
}

__device__ __device__ color operator*(const color& c, float a)
{
	return color
	(
		c.r * a,
		c.g * a,
		c.b * a
	);
}

__device__ __device__ color operator*(float a, const color& c)
{
	return color
	(
		c.r * a,
		c.g * a,
		c.b * a
	);
}

__device__ __device__ color operator*(const color& c1, const color& c2)
{
	return color
	(
		c1.r * c2.r,
		c1.g * c2.g,
		c1.b * c2.b
	);
}

__device__ __device__ color operator/(const color& c, float a)
{
	return color
	(
		c.r / a,
		c.g / a,
		c.b / a
	);
}
