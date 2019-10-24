#include<iostream>
#include<math.h>
#include<stdlib.h>
#include<time.h>

#define N 2048
using namespace std;

void random_ints(int *vector, int size){
    for(int i=0; i<size; i++)
        vector[i] = rand()%10;
}

void copy_int_to_float(float *dest, int *src, int size){
    for(int i=0; i<size; i++)
        dest[i] = float(src[i]);
}

__global__ void min(int *vector){
    int tid = threadIdx.x;
    int step_size = 1;
    int number_of_threads = blockDim.x;
    
    while(number_of_threads > 0){
        if(tid < number_of_threads){
            int first_index = tid * step_size *2;
            int second_index = first_index + step_size;
            vector[first_index] = vector[first_index] > vector[second_index] ? vector[second_index] : vector[first_index];
        }
        step_size <<= 1;
        number_of_threads >>= 1;
    }
}

__global__ void max(int *vector){
    int tid = threadIdx.x;
    int step_size = 1;
    int number_of_threads = blockDim.x;
    
    while(number_of_threads > 0){
        if(tid < number_of_threads){
            int first_index = tid * step_size *2;
            int second_index = first_index + step_size;
            vector[first_index] = vector[first_index] < vector[second_index] ? vector[second_index] : vector[first_index];
        }
        step_size <<= 1;
        number_of_threads >>= 1;
    }
}

__global__ void sum(int *vector){
    int tid = threadIdx.x;
    int step_size = 1;
    int number_of_threads = blockDim.x;
    
    while(number_of_threads > 0){
        if(tid < number_of_threads){ //If thread is alive
            int first_index = tid * step_size * 2; //As each thread operates on 2 elements.
            int second_index = first_index + step_size;
            
            vector[first_index] += vector[second_index];
        }
        step_size <<= 1;
        number_of_threads >>= 1;
    }
}

__global__ void sum_floats(float *vector){
    int tid = threadIdx.x;
    int step_size = 1;
    int number_of_threads = blockDim.x;
    
    while(number_of_threads > 0){
        if(tid < number_of_threads){ //If thread is alive
            int first_index = tid * step_size * 2; //As each thread operates on 2 elements.
            int second_index = first_index + step_size;
            
            vector[first_index] += vector[second_index];
        }
        step_size <<= 1;
        number_of_threads >>= 1;
    }
}

__global__ void mean_diff_sq(float *vector, float mean){ //Calculates (x - x')^2
    vector[threadIdx.x] -= mean;
    vector[threadIdx.x] *= vector[threadIdx.x];
}

int main(void){
    int size = N * sizeof(int);
    int *vec; //Host copy of vec
    int *d_vec; //Device copy of vec
    int result;
    
    srand(time(0));

    vec = (int *)malloc(size);
    random_ints(vec, N);

    cudaMalloc((void **)&d_vec, size);
    
    //SUM
    cudaMemcpy(d_vec, vec, size, cudaMemcpyHostToDevice);
    sum<<<1, N/2>>>(d_vec);
    //Copy the first element of array back to result
    cudaMemcpy(&result, d_vec, sizeof(int), cudaMemcpyDeviceToHost);
    printf("Sum is: %d", result);


    //MIN
    cudaMemcpy(d_vec, vec, size, cudaMemcpyHostToDevice);
    min<<<1, N/2>>>(d_vec);
    //Copy the first element of array back to result
    cudaMemcpy(&result, d_vec, sizeof(int), cudaMemcpyDeviceToHost);
    printf("\\nMin is: %d", result);
    
    
    //MAX
    cudaMemcpy(d_vec, vec, size, cudaMemcpyHostToDevice);
    max<<<1, N/2>>>(d_vec);
    //Copy the first element of array back to result
    cudaMemcpy(&result, d_vec, sizeof(int), cudaMemcpyDeviceToHost);
    printf("\\nMax is: %d", result);
    
    
    //MEAN
    cudaMemcpy(d_vec, vec, size, cudaMemcpyHostToDevice);
    sum<<<1, N/2>>>(d_vec);
    //Copy the first element of array back to result
    cudaMemcpy(&result, d_vec, sizeof(int), cudaMemcpyDeviceToHost);
    float mean = float(result)/N;
    printf("\\nMean is: %f", mean);
    
    
    //STD. DEV
    float *float_vec;
    float *d_float_vec;
    
    float_vec = (float *)malloc(N*sizeof(float));
    cudaMalloc((void **)&d_float_vec, N*sizeof(float));
    
    copy_int_to_float(float_vec, vec, N);
    
    cudaMemcpy(d_float_vec, float_vec, N*sizeof(float), cudaMemcpyHostToDevice);
    
    mean_diff_sq<<<1, N>>>(d_float_vec, mean);
    sum_floats<<<1, N/2>>>(d_float_vec);
    
    float res;
    cudaMemcpy(&res, d_float_vec, sizeof(res), cudaMemcpyDeviceToHost);
    
    res /= N;
    printf("\\nVariance: %f", res);
    res = sqrt(res);
    printf("\\nStd. Dev: %f", res);
    
    
    //Free allocated memory
    cudaFree(d_vec);
    
    printf("\\n");
    return 0;
}