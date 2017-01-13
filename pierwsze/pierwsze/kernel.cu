
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <time.h>

cudaError_t addWithCuda(unsigned long long int  liczba, bool &pierwsza);
bool CPU_sprawdz(unsigned long long int liczba);


#define NUM_THREADS   512
#define NUM_BLOCKS    1024

__global__ void addKernel(unsigned long long int *liczba, bool *pierwsza)
{
	if (*pierwsza == true) {
		unsigned long long int idx = 2 * (blockIdx.x*blockDim.x + threadIdx.x) + 3;
		while (idx*idx <= *liczba) {
			if (*liczba % (idx) == 0)  *pierwsza = false;
			if (*pierwsza == false) return;
			idx += blockDim.x*gridDim.x;
			if (idx*idx > *liczba) break;

		}

	}

}





int main()
{


	unsigned long long int liczba = 2 ^ 64 - 1;
	bool pierwsza;
	clock_t t1, t2;
	printf("Podaj liczbe:");
	scanf("%llu", &liczba);
	while (liczba > 18446744073709551615) {
		printf("Podaj liczbe:");
		scanf("%llu", &liczba);
	}
	t1 = clock();

	//pierwsza = CPU_sprawdz(liczba);

	t2 = clock();
	//printf("CPU   wynik: %d w %lf \n", pierwsza, (double)(t2-t1)/CLOCKS_PER_SEC);




	// Add vectors in parallel.
	cudaError_t cudaStatus = addWithCuda(liczba, pierwsza);
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "addWithCuda failed!");
		return 1;
	}










	///printf("{1,2,3,4,5} + {10,20,30,40,50} = {%d,%d,%d,%d,%d}\n",
	//    c[0], c[1], c[2], c[3], c[4]);


	// cudaDeviceReset must be called before exiting in order for profiling and
	// tracing tools such as Nsight and Visual Profiler to show complete traces.

	cudaStatus = cudaDeviceReset();

	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaDeviceReset failed!");
		return 1;
	}

	return 0;
}


bool CPU_sprawdz(unsigned long long int liczba) {
	for (unsigned long long int i = 2; i < liczba; i++) {

		if (liczba % i == 0) {
			printf("%d , %d \n", liczba, i);
			return false;
		}

	}
	return true;
}

// Helper function for using CUDA to add vectors in parallel.
cudaError_t addWithCuda(unsigned long long int liczba, bool &pierwsza)
{
	pierwsza = true;
	unsigned long long int *dev_liczba = NULL;
	unsigned long long int *dev_zakres = NULL;
	bool *dev_pierwsza = NULL;
	cudaError_t cudaStatus;
	clock_t t1, t2;
	float time_GPU = 0;

	// Choose which GPU to run on, change this on a multi-GPU system.
	cudaStatus = cudaSetDevice(0);
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaSetDevice failed!  Do you have a CUDA-capable GPU installed?");
		goto Error;
	}

	if (liczba % 2 == 0) pierwsza = false;
	else {
		cudaEvent_t start, stop;


		cudaEventCreate(&start);
		cudaEventCreate(&stop);

		cudaEventRecord(start, 0);

		// Allocate GPU buffers for three vectors (two input, one output)    .
		cudaStatus = cudaMalloc((void**)&dev_liczba, sizeof(unsigned long long int));
		if (cudaStatus != cudaSuccess) {
			fprintf(stderr, "cudaMalloc failed!1");
			goto Error;
		}

		cudaStatus = cudaMalloc((void**)&dev_pierwsza, sizeof(bool));
		if (cudaStatus != cudaSuccess) {
			fprintf(stderr, "cudaMalloc failed!2");
			goto Error;
		}




		// Copy input vectors from host memory to GPU buffers.
		cudaStatus = cudaMemcpy(dev_liczba, &liczba, sizeof(unsigned long long int), cudaMemcpyHostToDevice);
		if (cudaStatus != cudaSuccess) {
			fprintf(stderr, "cudaMemcpy failed3!");
			goto Error;
		}


		cudaStatus = cudaMemcpy(dev_pierwsza, &pierwsza, sizeof(bool), cudaMemcpyHostToDevice);
		if (cudaStatus != cudaSuccess) {
			fprintf(stderr, "cudaMemcpy failed!4");
			goto Error;
		}



		// Launch a kernel on the GPU with one thread for each element.






		addKernel << < NUM_BLOCKS, NUM_THREADS >> > (dev_liczba, dev_pierwsza);









		// Check for any errors launching the kernel
		cudaStatus = cudaGetLastError();
		if (cudaStatus != cudaSuccess) {
			fprintf(stderr, "addKernel launch failed: %s\n", cudaGetErrorString(cudaStatus));
			goto Error;
		}

		// cudaDeviceSynchronize waits for the kernel to finish, and returns
		// any errors encountered during the launch.
		cudaStatus = cudaDeviceSynchronize();
		if (cudaStatus != cudaSuccess) {
			fprintf(stderr, "cudaDeviceSynchronize returned error code %d after launching addKernel!\n", cudaStatus);
			goto Error;
		}

		// Copy output vector from GPU buffer to host memory.
		cudaStatus = cudaMemcpy(&pierwsza, dev_pierwsza, sizeof(bool), cudaMemcpyDeviceToHost);
		if (cudaStatus != cudaSuccess) {
			fprintf(stderr, "cudaMemcpy failed5!");
			goto Error;
		}
		cudaEventRecord(stop, 0);
		cudaEventSynchronize(stop);
		cudaEventElapsedTime(&time_GPU, start, stop);

		cudaEventDestroy(start);
		cudaEventDestroy(stop);
	}




	printf("GPU wynik: %d w czasie: %LF ms \n", pierwsza, time_GPU);



Error:
	cudaFree(dev_liczba);
	cudaFree(dev_pierwsza);


	return cudaStatus;
}
