#pragma once
#include "cuda_runtime.h"
#include "math.h"
#include <iostream>

#define IDENTITY2x2 square_matrix<2> ({1,0, 0,1})
#define IDENTITY3x3 square_matrix<3> ({1,0,0, 0,1,0, 0,0,1})
#define IDENTITY4x4 square_matrix<4> ({1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1})

class point
{
public:
	float x;
	float y;
	float z;
	float w;
	float body[4];

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
	float body[4];

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

//header only
template <int size>
class square_matrix
{
public:
	float matrix[size * size];

	__device__ square_matrix()
	{
		for (int i = 0; i < size * size; i++)
			matrix[i] = 0;
	}

	__device__ square_matrix(std::initializer_list<float> list)
	{
		static_assert(size == 2 || size == 3 || size == 4, "Unsuported matrix size");
		memcpy(matrix, list.begin(), size * size * sizeof(float));
	}
	__device__ float get_element(int row, int column)
	{
		assert(row < size && row >= 0);
		assert(column < size && column >= 0);
		return matrix[row + column * size];
	}
	__device__ bool operator==(const square_matrix<size>& matrix_B) const
	{
		bool is_equal = true;

		for (int i = 0; i < size * size; i++)
		{
			if (fabs(matrix[i] - matrix_B.matrix[i]) > FLT_EPSILON)
			{
				is_equal = false;
				break;
			}
		}
		return is_equal;
	}

	__device__ bool operator!=(const square_matrix<size>& matrix_B) const
	{
		return !((*this) == matrix_B);
	}

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

//header only
template <int size>
__device__ square_matrix<size> operator*(const square_matrix<size>& mat, float a)
{
	square_matrix<size> matrix_to_return;
	for (int i = 0; i < size * size; i++)
		matrix_to_return.matrix[i] = mat.matrix[i] * a;
	return matrix_to_return;
}

template <int size>
__device__ square_matrix<size> operator*(float a, const square_matrix<size>& mat)
{
	square_matrix<size> matrix_to_return;
	for (int i = 0; i < size * size; i++)
		matrix_to_return.matrix[i] = mat.matrix[i] * a;
	return matrix_to_return;
}

template <int size>
__device__ square_matrix<size> operator/(const square_matrix<size>& mat, float a)
{
	assert(a > FLT_MAX, "zero division");

	square_matrix<size> matrix_to_return;
	for (int i = 0; i < size * size; i++)
		matrix_to_return.matrix[i] = mat.matrix[i] / a;
	return matrix_to_return;
}

//header only
template <int size>
__device__ square_matrix<size> operator*(const square_matrix<size> &A, const square_matrix<size>& B)
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
	return result;
}

//header only
template <int size>
__device__ square_matrix<size> transpose(square_matrix<size> mat)
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
__device__ void print_matrix(const square_matrix<size>& mat)
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

__device__ vector operator*(const square_matrix<4> & matr, const vector& vec);

__device__ point operator*(const square_matrix<4>& matr, const point& vec);

__device__ float determinant(const square_matrix<2>& mat);

__device__ float determinant(const square_matrix<3>& mat);

__device__ float determinant(const square_matrix<4>& mat);

//header only
template <int size>
__device__ bool is_invertible(const square_matrix<size>& mat)
{
	return (fabs(determinant(mat)) > FLT_EPSILON);
}

__device__ square_matrix<3> minor_matrix(const square_matrix<4>& mat, int row_index, int column_index);

__device__ square_matrix<4> cofactor_matrix(const square_matrix<4>& mat);

__device__ square_matrix<4> inverse(const square_matrix<4>& mat);