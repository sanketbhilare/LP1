#include<iostream>
#include<omp.h>
#include<chrono>
#include<time.h>

using namespace std;
using namespace std::chrono;

class Node
{
  public:
	int val;
	Node *left;
	Node *right;
	
	Node(int val)
	{
		this->val = val;
		this->left = NULL;
		this->right = NULL;
	}	
};

void serial_dfs(Node *t)
{
	if(t == NULL)
		return;
		
	serial_dfs(t->left);
	cout<<t->val<<"  ";
	serial_dfs(t->right);
}

void parallel_dfs(Node *t)
{
	if(t == NULL)
		return;

	
	
	#pragma omp parallel sections
	{
		#pragma omp section
		{
			parallel_dfs(t->left);
		}
		cout<<t->val<<"  ";
		#pragma omp section
		{
			parallel_dfs(t->right);
		}
	}	
}

int main()
{
	int n = 100000;
	int arr[n];
	
	for(int i=0;i<n;i++)
		arr[i] = rand()%100;
	
	Node *root = NULL;
	
	if(root == NULL)
	{
		Node *node = new Node(arr[0]);
		root  = node;
	}
	
	for(int i=1;i<n;i++)
	{
		Node *n = new Node(arr[i]);
		Node *temp = root;
		
		while(temp != NULL)
		{using namespace std::chrono;
			if(temp->val > arr[i])
			{
				if(temp->left != NULL)
					temp = temp->left;
				else
				{
					temp->left = n;
					break;
				}
			}
			
			else
			{
				if(temp->right != NULL)
					temp = temp->right;
				else
				{
					temp->right = n;
					break;
				}
			}
		}	
	}
		
	time_point<system_clock> start,end;
	
	start = system_clock::now();
	serial_dfs(root);
	end = system_clock::now();
	duration<double> t = end-start;
	cout<<"The time required for serial is :- "<<t.count()*1000<<endl;
	
	start = system_clock::now();
	parallel_dfs(root);
	end = system_clock::now();
	t = end-start;
	cout<<"The time required for parallel is :- "<<t.count()*1000<<endl;
	
	return 0;
}