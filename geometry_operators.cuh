#pragma once
#include "cuda_runtime.h"


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

class vector : public point
{
public:
	__device__ vector(float x, float y, float z);
};

__device__ bool is_point(const point& p);

__device__ bool is_vector(const point& v);

__device__ vector operator+(const vector& p1, const vector& p2);

__device__ point operator+(const vector& v, const point& p);

__device__ point operator+(const point& v, const vector& p);

__device__ vector operator-(const point& p, const vector& v);
