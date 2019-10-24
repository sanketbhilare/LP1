#include <bits/stdc++.h>
#include <omp.h>
#include <chrono>
#include "tree.hpp"
using namespace std;
using namespace std::chrono;

bool serial_dfs(Node *root, int element){
	if(root != NULL){
		if(root->data == element){
			return true;
		}
		else{
			return serial_dfs(root->left, element) || serial_dfs(root->right, element);
		}
	}
	return false;
}

void parallel_dfs(Node *root, int element){
	if(root != NULL){
		if(root->data == element){
			cout << "<Found> Parallel: true" << endl;
			return;
		}
		#pragma omp parallel sections
		{
			
			#pragma omp section
			{
				parallel_dfs(root->left, element);
			}

			#pragma omp section
			{
				parallel_dfs(root->right, element);
			}
		}
	}
}

int main(){

	Tree t = Tree();

	for(int i = 0;i < 100000;i ++){
		t.addNode(i);
	}
	
	int element = 999;
	auto serial_start = high_resolution_clock::now();
	bool flag = serial_dfs(t.returnRoot(), element);
	auto serial_stop = high_resolution_clock::now();
	auto serial_duration = duration_cast<microseconds>(serial_stop - serial_start).count();
	cout << "<Found> Serial: " << flag << endl;
	cout << "<Timing> Serial: " << serial_duration << " us" << endl;
	
	auto parallel_start = high_resolution_clock::now();
	parallel_dfs(t.returnRoot(), element);
	auto parallel_stop = high_resolution_clock::now();
	auto parallel_duration = duration_cast<microseconds>(parallel_stop - parallel_start).count();
	cout << "<Timing> Parallel: " << parallel_duration << " us" << endl;
	
	return 0;
}