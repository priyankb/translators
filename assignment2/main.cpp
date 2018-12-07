//#include <stdio.h>
#include <stdlib.h>
#include "scanner.h"
#include <iostream>
#include <string>
#include <vector>
#include <cstring>
#include <set>

extern int yylex();
extern int yylineno;
extern char* yytext;
extern std::vector<std::string*> lines; 
extern std::set<std::string> myset;

using namespace std;

int main(){
   //printf("Running Lex....\n");
   //int token;
   //token = yylex();
   std::vector<std::string*>::iterator vecIter;
   std::set<std::string>::iterator setIter;
   if(!yylex()){
      printf("#include <iostream>\n");
      printf("int main(){\n");
      
      /*if(lines.empty()){
	 cout << "is empty" << endl;
      }
      else{
	 cout << "not empty" << endl;
      }*/
      for(setIter = myset.begin(); setIter != myset.end(); ++setIter){
	 cout << "double " << *setIter << ";" << endl;
      }
      cout << endl;
      for(vecIter = lines.begin(); vecIter != lines.end(); ++vecIter){
	 cout << **vecIter << endl;
      }
      cout << "}" << endl;
   }


   return 0;


}
