#pragma once
#include "cuda_runtime.h"
#include "math.h"


class point
{
public:
	float x;
	float y;
	float z;
	float w;

	__device__ point();

	__device__ point(float x, float y, float z);
};

class vector
{
public:
	float x;
	float y;
	float z;
	float w;

	__device__ vector();

	__device__ vector(float x, float y, float z);

	__device__ vector operator-() const;

	__device__ float length() const;

	__device__ vector normalize() const;
};

class color
{
public:
	float r;
	float g;
	float b;

	__device__ color();
	
	__device__ color(float x, float y, float z);
};

__device__ bool is_point(const point& p);

__device__ bool is_vector(const point& v);

__device__ vector operator+(const vector& p1, const vector& p2);

__device__ point operator+(const vector& v, const point& p);

__device__ point operator+(const point& v, const vector& p);

__device__ vector operator-(const point& point_1, const point& point_2);

__device__ point operator-(const point& p, const vector& v);

__device__ vector operator-(const vector& v1, const vector& v2);

__device__ vector operator*(const vector& v, float a);

__device__ vector operator*(float a, const vector& v);

__device__ vector operator*(const vector& v, const vector& v2);

__device__ vector operator/(const vector& v, float a);

__device__ float dot(const vector& v1, const vector& v2);

__device__ vector cross(const vector& v1, const vector& v2);

__device__ color operator+(const color& c1, const color& c2);

__device__ color operator-(const color& c1, const color& c2);

__device__ color operator*(const color& c, float a);

__device__ color operator*(float a, const color& c);

__device__ color operator*(const color& c1, const color& c2);

__device__ color operator/(const color& c, float a);