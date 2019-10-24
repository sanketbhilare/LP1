#include <bits/stdc++.h>
using namespace std;

class Node{
	public:
	int data;
	Node *left, *right;
	Node(){
		left = NULL;
		right = NULL;
	}
	Node(int d){
		data = d;
		left = NULL;
		right = NULL;
	}
};

class Tree{
	public:
	Node *root;
	Tree(){
		root = NULL;
	}

	void addNode(int d){
		if(root == NULL){
			root = new Node(d);
		}
		else{
			Node *c = root;
			while(true){
				if(c->data > d){
					if(c->left == NULL){
						c->left = new Node(d);
						break;
					}
					c = c->left;
				}
				else{
					if(c->right == NULL){
						c->right = new Node(d);
						break;
					}
					c = c->right;
				}
			}
		}
	}

	Node* returnRoot(){
		return root;
	}
};