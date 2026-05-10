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
	
	for (int i = 0; i < 4; i++)
		if (fabs(ret[i]) < MATR_EPSILON)
			ret[i] = 0;

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

	for (int i = 0; i < 4; i++)
		if (fabs(ret[i]) < MATR_EPSILON)
			ret[i] = 0;

	return point(ret[0], ret[1], ret[2]);
}

__device__ float determinant(const square_matrix<2>& mat)
{
	return mat.matrix[0] * mat.matrix[3] - mat.matrix[1] * mat.matrix[2];
}

__device__ float determinant(const square_matrix<3>& mat)
{
	square_matrix<2> sub_mat1({ mat.matrix[3], mat.matrix[4], mat.matrix[6], mat.matrix[7] });
	square_matrix<2> sub_mat2({ mat.matrix[3], mat.matrix[5], mat.matrix[6], mat.matrix[8] });
	square_matrix<2> sub_mat3({ mat.matrix[4], mat.matrix[5], mat.matrix[7], mat.matrix[8] });

	return 
		mat.matrix[0] * determinant(sub_mat3) -
		mat.matrix[1] * determinant(sub_mat2) + 
		mat.matrix[2] * determinant(sub_mat1);
}

__device__ float determinant(const square_matrix<4>& mat)
{
	square_matrix<3> sub_mat1({
		mat.matrix[5], mat.matrix[6], mat.matrix[7],
		mat.matrix[9], mat.matrix[10],mat.matrix[11],
		mat.matrix[13],mat.matrix[14],mat.matrix[15]
		});
	square_matrix<3> sub_mat2({
		mat.matrix[4], mat.matrix[6], mat.matrix[7],
		mat.matrix[8], mat.matrix[10],mat.matrix[11],
		mat.matrix[12],mat.matrix[14],mat.matrix[15]
		});
	square_matrix<3> sub_mat3({
		mat.matrix[4], mat.matrix[5], mat.matrix[7],
		mat.matrix[8], mat.matrix[9],mat.matrix[11],
		mat.matrix[12],mat.matrix[13],mat.matrix[15]
		});
	square_matrix<3> sub_mat4({
		mat.matrix[4], mat.matrix[5], mat.matrix[6],
		mat.matrix[8], mat.matrix[9], mat.matrix[10],
		mat.matrix[12],mat.matrix[13],mat.matrix[14] 
		});

	return
		mat.matrix[0] * determinant(sub_mat1) -
		mat.matrix[1] * determinant(sub_mat2) +
		mat.matrix[2] * determinant(sub_mat3) -
		mat.matrix[3] * determinant(sub_mat4) ;
}

__device__ square_matrix<3> minor_matrix(const square_matrix<4>& mat, 
	int row_index_of_element, int column_index_of_element)
{
	int smaller_traversal_index = 0;
	square_matrix<3> matrix_to_return;
	for (int index = 0; index < 16; index++)
	{
		if (((index % 4) == column_index_of_element) || ((index / 4) == row_index_of_element))
			continue;
		matrix_to_return.matrix[smaller_traversal_index] = mat.matrix[index];
		smaller_traversal_index++;
	}
	return matrix_to_return;
}

__device__ square_matrix<4> cofactor_matrix(const square_matrix<4>& mat)
{
	square_matrix<4> cofactor_matrix;
	square_matrix<3> temporary_values_holding_matrix;
	int sign = -1;
	for (int column = 0; column < 4; column++)
	{
		for (int row = 0; row < 4; row++)
		{
			cofactor_matrix.matrix[column + row * 4] =
				pow(sign, row + column) * determinant(minor_matrix(mat, row, column));
		}
	}
	return cofactor_matrix;
}

__device__ square_matrix<4> inverse(const square_matrix<4>& mat)
{
	if (is_invertible(mat))
		return transpose(cofactor_matrix(mat)) / determinant(mat);
	
	printf("Matrix is not invertible, identity retrunerd.\n");
	return IDENTITY4x4;
}
// 0, 1, 2, 3 
// 4, 5, 6, 7
// 8, 9, 10, 11,
// 12, 13, 14, 15