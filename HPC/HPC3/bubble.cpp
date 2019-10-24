#include<iostream>
#include<chrono>
#include"omp.h"
#include<stdio.h>

using namespace std;
using namespace std::chrono;

void serial(int a[], int n)
{

	time_point<system_clock> starttime, endtime;
	starttime = system_clock::now();
	for (int i = 0; i < n-1; i++)
	{
		for (int j = 0; j <n-1; j++)
		{
			if(a[j]>a[j+1])
			{
				int temp = a[j];
				a[j] = a[j+1];
				a[j+1] = temp;
			}
		}
	}

	endtime = system_clock::now();
	duration <double> time= endtime - starttime;

	cout<<"Time for serial : "<<1000*time.count()<<endl;
}

void parallel(int b[], int n)
{
	time_point<system_clock> starttime, endtime;
	starttime = system_clock::now();
	int first;

	omp_set_num_threads(2);

	for(int i = 0 ; i<n-1; i++)
	{
		first = i%2;
		#pragma omp parallel for default(none), shared(b,first,n)
		for (int j=first; j<n-1; j+=2)
		{
			if(b[j]>b[j+1])
			{
				int temp = b[j];
				b[j] = b[j+1];
				b[j+1]=temp;	
			}
		}
	}
	endtime = system_clock::now();
	duration<double> time = endtime - starttime;

	cout<<"Time for Parallel : "<<1000*time.count()<<endl;
}




int main()
{
	int n;
	cin>>n;

	int a[n],b[n];

	for(int i = 0; i < n; i++)
	{
		a[i] = b[i] = rand()%n;
	}

	serial(a,n);

	parallel(b,n);





	return 0;
}