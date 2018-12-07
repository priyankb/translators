#include <iostream>

using namespace std;

struct node{
    string val = "";
    int type;	//1 = assign, 2 = if, 3 = while
    struct node* left = NULL;
    struct node* right = NULL;
    node(string x){
	val = x;
    }
};


