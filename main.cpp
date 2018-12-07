#include <stdio.h>
#include <stdlib.h>
#include "scanner.h"

extern int yylex();
extern int yylineno;
extern char* yytext;

int main(){
   printf("Running Lex....\n");
   int token;
   token = yylex();
   //printf("We done!");	yyterminate() brings control here
   
   //printf("Token: %d", token);
   /*while(token){
      printf("Token: %d", token);
      printf("Text: %s\n", yytext);
      token = yylex();
   }*/


   return 0;


}
