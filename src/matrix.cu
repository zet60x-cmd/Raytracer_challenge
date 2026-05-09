#include "geometry_operators.cuh"

__device__ vector operator*(const square_matrix<4>& matr, const vector& vec)
{
	float ret[4];
	for (int column = 0; column < 3; column++)
	{
		ret[column] =
			matr.matrix[0 + column * 4] * vec.x +
			matr.matrix[1 + column * 4] * vec.y +
			matr.matrix[2 + column * 4] * vec.z +
			matr.matrix[3 + column * 4] * vec.w;
	}
	return vector(ret[0], ret[1], ret[2]);
}

__device__ point operator*(const square_matrix<4>& matr, const point& p)
{
	float ret[3];
	for (int column = 0; column < 3; column++)
	{
		ret[column] =
			matr.matrix[0 + column * 4] * p.x +
			matr.matrix[1 + column * 4] * p.y +
			matr.matrix[2 + column * 4] * p.z +
			matr.matrix[3 + column * 4] * p.w;
	}
	return point(ret[0], ret[1], ret[2]);
}