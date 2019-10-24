#include<stdio.h>
#include<stdlib.h>
#define size 10

__global__ void vectMatMul(int *a, int *b, int*c, int n)
{
    int id = threadIdx.x;
    if(id<n)
    {
      for( int j=0;j<size; j++)
      {
          c[id] = c[id] + (a[j] * b[id*n + j]);
      }
    }
}




int main()
{
    int *A,*B,*C;
    A = (int*)malloc(size * sizeof(int));
    B = (int*)malloc(size * size * sizeof(int));
    C = (int*)malloc(size * sizeof(int));
    
    
    for(int i=0; i<size;i++)
    {
        A[i] = rand()%10;
        for(int j=0; j<size; j++)
        {
            *(B + i*size + j) = rand()%10;
        }
    }
    
    
    int *AD, *BD, *CD;
    
    cudaMalloc(&AD, size*sizeof(int));
    cudaMalloc(&BD, size*size*sizeof(int));
    cudaMalloc(&CD, size*sizeof(int));
    
    cudaMemcpy(AD, A, size*sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(BD, B, size*size*sizeof(int), cudaMemcpyHostToDevice);
    
    vectMatMul<<<1,size>>>(AD, BD, CD, size);
    
    cudaMemcpy(C, CD, size*sizeof(int), cudaMemcpyDeviceToHost);
    
    
    
    printf("Vector: \n");
	for (int i = 0; i < size; i++)
	{
		printf("%d ", A[i]);
	}
	printf("\n");
	printf("Matrix: \n");
	for (int i = 0; i < size; i++)
	{
		for (int j = 0; j < size; j++)
		{
			printf("%d ", *(B + i*size + j));
		}
		printf("\n");
	}
	printf("Product: \n");
	for (int i = 0; i < size; i++)
	{
		printf("%d ", C[i]);
	}
	printf("\n");
    
    
    cudaFree(AD);
    cudaFree(BD);
    cudaFree(CD);
    
    free(A);
    free(B);
    free(C);
    
    return 0;
}
