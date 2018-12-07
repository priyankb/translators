//#include <stdio.h>
#include <stdlib.h>
//#include "scanner.h"
using namespace std;
#include <iostream>
#include "parser.hpp"
#include "node.hpp"
#include <string>
#include <vector>
#include <cstring>

extern int yylex();
extern int yylineno;
extern char* yytext;
extern std::vector<std::string*> lines; 
extern struct node* head_node;



void printNodes(struct node*);

int main(){
   printf("Running Lex....\n");
   //int token;
   //token = yylex();
   std::vector<std::string*>::iterator it;
   if(!yylex()){
      printf("#include <iostream>\n");
      printf("int main(){\n");      
      cout << head_node->val << endl;
      printNodes(head_node);
   }
   
   return 0;
}
//intended to print all nodes in order to determine correctness of parser
void printNodes(struct node* head){
   if(head != NULL){
      printNodes(head->left);
      if(head->left != NULL && head->right != NULL){
	 cout << head->val << " ";
      }
      printNodes(head->right);
   }
}
