#pragma once
#include <cuda_runtime.h>
#include "assert.h"
#include "math.h"
#include <iostream>

#define IDENTITY2x2 square_matrix<2> ({1,0, 0,1})
#define IDENTITY3x3 square_matrix<3> ({1,0,0, 0,1,0, 0,0,1})
#define IDENTITY4x4 square_matrix<4> ({1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1})
#define TRANSLATION(x, y, z) square_matrix<4> ({1,0,0,x, 0,1,0,y, 0,0,1,z, 0,0,0,1})
#define SCALING(x, y, z) square_matrix<4> ({x,0,0,0, 0,y,0,0, 0,0,z,0, 0,0,0,1})
#define ROTATION_X(r) square_matrix<4> ({1,0,0,0, 0,cos(r),-sin(r),0, 0,sin(r),cos(r),0, 0,0,0,1})
#define ROTATION_Y(r) square_matrix<4> ({cos(r),0,sin(r),0, 0,1,0,0, -sin(r),0,cos(r),0, 0,0,0,1})
#define ROTATION_Z(r) square_matrix<4> ({cos(r),-sin(r),0,0, sin(r),cos(r),0,0, 0,0,1,0, 0,0,0,1})
#define SHEAR(x_y, x_z, y_x, y_z, z_x, z_y) square_matrix<4> ({1,x_y,x_z,0, y_x,1,y_z,0, z_x,z_y,1,0, 0,0,0,1})
#define MATR_EPSILON 0.00001f

class point
{
public:
	float x;
	float y;
	float z;
	float w;
	float body[4];

	__host__ __device__ point();

	__host__ __device__ point(float x, float y, float z);

	__host__ __device__ float operator[](int i) const;

	__host__ __device__ void print_point() const;
};

class vector
{
public:
	float x;
	float y;
	float z;
	float w;
	float body[4];

	__host__ __device__ vector();

	__host__ __device__ vector(float x, float y, float z);

	__host__ __device__ vector operator-() const;

	__host__ __device__ float operator[](int i) const;

	__host__ __device__ float length() const;

	__host__ __device__ vector normalize() const;

	__host__ __device__ void print_vector() const;
};

class color
{
public:
	float r;
	float g;
	float b;

	__host__ __device__ color();
	
	__host__ __device__ color(float x, float y, float z);

	__host__ __device__ void print_color() const;
};

//header only
template <int size>
class square_matrix
{
public:
	float matrix[size * size];

	__host__ __device__ square_matrix()
	{
		for (int i = 0; i < size * size; i++)
			matrix[i] = 0;
	}

	__host__ __device__ square_matrix(std::initializer_list<float> list)
	{
		static_assert(size == 2 || size == 3 || size == 4, "Unsuported matrix size");
		memcpy(matrix, list.begin(), size * size * sizeof(float));
	}
	__host__ __device__ float get_element(int row, int column)
	{
		assert(row < size && row >= 0);
		assert(column < size && column >= 0);
		return matrix[row + column * size];
	}
	__host__ __device__ bool operator==(const square_matrix<size>& matrix_B) const
	{
		bool is_equal = true;

		for (int i = 0; i < size * size; i++)
		{
			if (fabs(matrix[i] - matrix_B.matrix[i]) > MATR_EPSILON)
			{
				is_equal = false;
				break;
			}
		}
		return is_equal;
	}

	__host__ __device__ bool operator!=(const square_matrix<size>& matrix_B) const
	{
		return !((*this) == matrix_B);
	}

};

__host__ __device__ bool is_point(const point& p);

__host__ __device__ bool is_vector(const point& v);

__host__ __device__ vector operator+(const vector& p1, const vector& p2);

__host__ __device__ point operator+(const vector& v, const point& p);

__host__ __device__ point operator+(const point& v, const vector& p);

__host__ __device__ vector operator-(const point& point_1, const point& point_2);

__host__ __device__ point operator-(const point& p, const vector& v);

__host__ __device__ vector operator-(const vector& v1, const vector& v2);

__host__ __device__ vector operator*(const vector& v, float a);

__host__ __device__ vector operator*(float a, const vector& v);

__host__ __device__ vector operator*(const vector& v, const vector& v2);

__host__ __device__ vector operator/(const vector& v, float a);

__host__ __device__ float dot(const vector& v1, const vector& v2);

__host__ __device__ vector cross(const vector& v1, const vector& v2);

__host__ __device__ color operator+(const color& c1, const color& c2);

__host__ __device__ color operator-(const color& c1, const color& c2);

__host__ __device__ color operator*(const color& c, float a);

__host__ __device__ color operator*(float a, const color& c);

__host__ __device__ color operator*(const color& c1, const color& c2);

__host__ __device__ color operator/(const color& c, float a);

//header only
template <int size>
__host__ __device__ square_matrix<size> operator*(const square_matrix<size>& mat, float a)
{
	square_matrix<size> matrix_to_return;
	for (int i = 0; i < size * size; i++)
		matrix_to_return.matrix[i] = mat.matrix[i] * a;
	return matrix_to_return;
}

//header only
template <int size>
__host__ __device__ square_matrix<size> operator*(float a, const square_matrix<size>& mat)
{
	square_matrix<size> matrix_to_return;
	for (int i = 0; i < size * size; i++)
		matrix_to_return.matrix[i] = mat.matrix[i] * a;
	return matrix_to_return;
}

template <int size>
__host__ __device__ square_matrix<size> operator/(const square_matrix<size>& mat, float a)
{
	assert(a > MATR_EPSILON, "zero division");

	square_matrix<size> matrix_to_return;
	for (int i = 0; i < size * size; i++)
		matrix_to_return.matrix[i] = mat.matrix[i] / a;
	return matrix_to_return;
}

//header only
template <int size>
__host__ __device__ square_matrix<size> operator*(const square_matrix<size> &A, const square_matrix<size>& B)
{
	square_matrix<size> result = square_matrix<size>();
	for (int column = 0; column < size; column++)
	{
		for (int column_B = 0; column_B < size; column_B++)
		{
			float sum = 0;
			for (int row = 0; row < size; row++)
			{
				sum += A.matrix[row + size * column] * B.matrix[column_B + size * row];
			}
			result.matrix[column_B + column * size] = sum;
		}
	}

	for (int i = 0; i < size * size; i++)
	{
		if (fabs(result.matrix[i]) < MATR_EPSILON)
			result.matrix[i] = 0;
	}
	return result;
}

//header only
template <int size>
__host__ __device__ square_matrix<size> transpose(square_matrix<size> mat)
{
	float value_holder = 0;
	for (int row = 0; row < size; row++)
	{
		int stride = size - 1;
		for (int column = row + 1; column < size; column++)
		{
			value_holder = mat.matrix[column + row * size];
			mat.matrix[column + row * size] = mat.matrix[column + row * size + stride];
			mat.matrix[column + row * size + stride] = value_holder;
			stride += (size - 1);
		}
	}
	return mat;
}
//header only
//added mostly for debugging purposes
template <int size>
__host__ __device__ void print_matrix(const square_matrix<size>& mat)
{
	for (int row = 0; row < size; row++)
	{
		for (int column = 0; column < size; column++)
		{
			printf("%f ", mat.matrix[column + row * size]);
		}
		printf("\n");
	}
}

__host__ __device__ vector operator*(const square_matrix<4> & matr, const vector& vec);

__host__ __device__ point operator*(const square_matrix<4>& matr, const point& vec);

__host__ __device__ float determinant(const square_matrix<2>& mat);

__host__ __device__ float determinant(const square_matrix<3>& mat);

__host__ __device__ float determinant(const square_matrix<4>& mat);

//header only
template <int size>
__host__ __device__ bool is_invertible(const square_matrix<size>& mat)
{
	return (fabs(determinant(mat)) > MATR_EPSILON);
}

__host__ __device__ square_matrix<3> minor_matrix(const square_matrix<4>& mat, int row_index, int column_index);

__host__ __device__ square_matrix<4> cofactor_matrix(const square_matrix<4>& mat);

__host__ __device__ square_matrix<4> inverse(const square_matrix<4>& mat);

__host__ __device__ vector reflect(const vector& inbound_vector,const vector& normal);