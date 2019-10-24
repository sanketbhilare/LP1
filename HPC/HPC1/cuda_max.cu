#include<math.h>
#include<time.h>
#include<stdexcept>
#include<iostream>
#include<cstdlib> //for abs(x)
#include<stdio.h>


using namespace std;

__global__ void findMax(int* A,int* current_max,int* mutex,unsigned int n);



int main()
{
	const int NUMBER_OF_ELEMENTS = 1024*1024*20;

	int* hostA = (int*)malloc(NUMBER_OF_ELEMENTS*sizeof(int));

	int* hostMax = (int*)malloc(sizeof(int));

	*hostMax = -1;

	srand(time(0));
	int i,j;

	//initialize host vector by random elements
	for(i=0;i<NUMBER_OF_ELEMENTS;i++)
	{
		hostA[i] = NUMBER_OF_ELEMENTS*rand() / RAND_MAX/123;
		
	}
	int* deviceA,*deviceMax,*deviceMutex;

	cudaMalloc(&deviceA,NUMBER_OF_ELEMENTS*sizeof(int));
	cudaMalloc(&deviceMax,sizeof(int));
	cudaMalloc(&deviceMutex,sizeof(int));

	cudaMemset(deviceMax,-1,sizeof(int));
	cudaMemset(deviceMutex,0,sizeof(int));

	cudaMemcpy(deviceA,hostA,NUMBER_OF_ELEMENTS*sizeof(int),cudaMemcpyHostToDevice);

	//set up timing variables

	float gpu_elapsed_time;
	cudaEvent_t gpu_start,gpu_stop;

	cudaEventCreate(&gpu_start);
	cudaEventCreate(&gpu_stop);

	cudaEventRecord(gpu_start,0);


	findMax<<<256,256>>>(deviceA,deviceMax,deviceMutex,NUMBER_OF_ELEMENTS);

	cudaDeviceSynchronize();

	cudaMemcpy(hostMax,deviceMax,sizeof(int),cudaMemcpyDeviceToHost);
	cudaEventRecord(gpu_stop, 0);
	cudaEventSynchronize(gpu_stop);
	cudaEventElapsedTime(&gpu_elapsed_time, gpu_start, gpu_stop);
	cudaEventDestroy(gpu_start);
	cudaEventDestroy(gpu_stop);

	cout<<"Answer by CUDA for MAX is = "<<*hostMax<<endl;
	std::cout<<"The gpu took: "<<gpu_elapsed_time<<" milli-seconds"<<std::endl;

	






	clock_t cpu_start = clock();

	int maxx = -1;

	for(int i=0;i<NUMBER_OF_ELEMENTS;i++)
	{
	if(hostA[i]>maxx)
	    maxx = hostA[i];
	}

	clock_t cpu_stop = clock();
	clock_t cpu_elapsed_time = 1000*(cpu_stop - cpu_start)/CLOCKS_PER_SEC;

	cout<<"Expected max value is = "<<maxx<<endl;

	std::cout<<"The cpu took: "<<cpu_elapsed_time<<" milli-seconds"<<std::endl;


	cudaFree(deviceA);

	delete[] hostA;

	return cudaDeviceSynchronize();
    	




    

    	



}
__global__ void findMax(int* A,int* current_max,int* mutex,unsigned int n)
{
		//printf("threadIdx.x = %d and blockIdx = %d and gridDim.x = %d\n",threadIdx.x,blockIdx.x,gridDim.x);

		unsigned int index = threadIdx.x + blockIdx.x*blockDim.x;
		unsigned int stride = gridDim.x*blockDim.x;

		unsigned int offset = 0;

		__shared__ int cache[256];

		int temp = -1;
		while(index+offset<n)
		{
		temp = fmaxf(temp,A[index+offset]);
		offset+=stride;
		}

		cache[threadIdx.x]=temp;

		__syncthreads();


		//reduction
		//printf("blockDim.x = %d\n",blockDim.x/2);
		unsigned int i=blockDim.x/2;
		while(i!=0)
		{
		if(threadIdx.x<i)
		{
		cache[threadIdx.x] = fmaxf(cache[threadIdx.x],cache[threadIdx.x+i]);

		}
		__syncthreads();
		i/=2;
		}

		if(threadIdx.x ==0)
		while(atomicCAS(mutex,0,1)!=0);
		*current_max = fmaxf(*current_max,cache[0]);
		atomicExch(mutex,0);


}


