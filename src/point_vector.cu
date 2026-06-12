#include "geometry_operators.cuh"

__device__ point::point()
{
	this->x = 0.0f;
	this->y = 0.0f;
	this->z = 0.0f;
	this->w = 1.0f;
	this->body[0] = 0;
	this->body[1] = 0;
	this->body[2] = 0;
	this->body[3] = 1.0f;
}

__device__ point::point(float x, float y, float z)
{
	this->x = x;
	this->y = y;
	this->z = z;
	this->w = 1.0f;
	this->body[0] = x;
	this->body[1] = y;
	this->body[2] = z;
	this->body[3] = 1.0f;
}

__device__ vector::vector()
{
	this->x = 0.0f;
	this->y = 0.0f;
	this->z = 0.0f;
	this->w = 0.0f;
	for (int i = 0; i < 4; i++)
		this->body[i] = 0;
}

__device__ vector::vector(float x, float y, float z)
{
	this->x = x;
	this->y = y;
	this->z = z;
	this->w = 0.0f;
	this->body[0] = x;
	this->body[1] = y;
	this->body[2] = z;
	this->body[3] = 0.0f;
}

__device__ float vector::operator[](int i) const
{
	return body[i];
}

__device__ float point::operator[](int i) const
{
	return body[i];
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

__device__ vector operator-(const point& p1, const point& p2)
{
	return vector(p1.x - p2.x,
				  p1.y - p2.y,
				  p1.z - p2.z);
}

__device__ point operator-(const point& p, const vector& v)
{
	return point(p.x - v.x,
				 p.y - v.y,
				 p.z - v.z);
}

__device__ void point::print_point() const
{
	printf("%f, %f, %f\n", this->x, this->y, this->z);
}

__device__ vector operator-(const vector& v1, const vector& v2)
{
	return vector(v1.x - v2.x,
				  v1.y - v2.y,
				  v1.z - v2.z);
}

__device__ vector vector::operator-() const
{
	vector return_vector
	{
		-this->x,
		-this->y,
		-this->z
	};

	// Hardfixing mistake with zero points being negative
	if (fabs(return_vector.x) <= MATR_EPSILON)
		return_vector.x = 0;
	if (fabs(return_vector.y) <= MATR_EPSILON)
		return_vector.y = 0;
	if (fabs(return_vector.z) <= MATR_EPSILON)
		return_vector.z = 0;

	return return_vector;
}

__device__ vector operator*(const vector& v, float a)
{
	return vector(v.x * a,
				  v.y * a,
				  v.z * a);
}

__device__ vector operator*(float a, const vector& v)
{
	return vector(v.x * a,
				  v.y * a,
				  v.z * a);
}

__device__ vector operator*(const vector& v1, const vector& v2)
{
	return vector(v1.x * v2.x,
				  v1.y * v2.y,
				  v1.z * v2.z);
}


__device__ vector operator/(const vector& v, float a)
{
	return vector(v.x / a,
				  v.y / a,
				  v.z / a);
}

__device__ float vector::length() const
{
	return sqrt(x * x + y * y + z * z);
}

__device__ vector vector::normalize() const
{
	float len = this->length();
	if (len < MATR_EPSILON)
		return *this;
	return vector(x, y, z) / (len);
}

__device__ void vector::print_vector() const
{
	printf("%f, %f, %f\n", this->x, this->y, this->z);
}

__device__ float dot(const vector& v1, const vector& v2)
{
	return  v1.x * v2.x +
			v1.y * v2.y +
			v1.z * v2.z;
}

__device__ vector cross(const vector& v1, const vector& v2)
{
	return vector(v1.y * v2.z - v1.z * v2.y,
				  v1.z * v2.x - v1.x * v2.z,
				  v1.x * v2.y - v1.y * v2.x);
}

__device__ vector reflect(const vector& inbound_vector, const vector& normal)
{
	return (inbound_vector - 2 * normal * dot(inbound_vector, normal));
}