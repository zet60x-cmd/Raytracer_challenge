#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <iostream>
#include "geometry_operators.cuh"

#define checkCudaErrors(val) check_cuda( (val), #val, __FILE__, __LINE__ )
void check_cuda(cudaError_t result, char const* const func, const char* const file, int const line) {
	if (result) {
		std::cerr << "CUDA error = " << static_cast<unsigned int>(result) << " at " <<
			file << ":" << line << " '" << func << "' \n";
		// Make sure we call CUDA Device Reset before exiting
		cudaDeviceReset();
		exit(99);
	}
}

__global__ void test()
{
	vector v1(3, -2, 5);
	point v2(-2, 3, 1);
	point v3 = v2 + v1;
	printf("%f,%f,%f,%f \n", v3.x, v3.y, v3.z, v3.w);
}

int main()
{

	test <<<1, 1 >>> ();
	checkCudaErrors(cudaDeviceSynchronize());
	return 0;
}