#include<stdio.h>
#include<math.h>
#include<stdlib.h>

__global__ void add(int *a, int *b, int *c, int N)
{
    int id = threadIdx.x + blockDim.x * blockIdx.x;
    
    c[id] = a[id] + b[id];
}

void random_ints(int* x, int size)
{
	int i;
	for (i=0;i<size;i++) {
		x[i]=rand()%size;
	}
}



int main()
{
    int N=100000;
    
    int size = N * sizeof(int);
    
    int *A, *B, *C;
    
    A = (int*)malloc(size);
    B = (int*)malloc(size);
    C = (int*)malloc(size);
    
    int *Ad, *Bd, *Cd;
    
    random_ints(A,N);
    random_ints(B,N);
    
    cudaMalloc(&Ad, size);
    cudaMalloc(&Bd, size);
    cudaMalloc(&Cd, size);
    
    cudaMemcpy(Ad, A, size, cudaMemcpyHostToDevice);
    cudaMemcpy(Bd, B, size, cudaMemcpyHostToDevice);
    
    dim3 blockSize(1024,1);
    dim3 gridSize(1,1);
    
    add <<<gridSize , blockSize>>>(Ad, Bd, Cd, N);
    
    cudaMemcpy(C, Cd, size, cudaMemcpyDeviceToHost);
    
    for(int i=0;i<5;i++)
    {
        printf("%d\t%d\t%d\n",A[i], B[i], C[i]);
    }
    
    cudaFree(Ad);
    cudaFree(Bd);
    cudaFree(Cd);
    
    free(A);
    free(B);
    free(C);
    
    return 0;
    
    
}