%option no yywrap

%{
//#include "scanner.h"
#include <iostream>
#include <stack>
#include "parser.hpp"
#include <string>


using namespace std;

std::stack<int> indents;
%}


%{

int status;
yypstate* ps = yypstate_new();
YYSTYPE val;
YYLTYPE loc;

int push(int myToken, char* value){
	
	val = new string(value);
	//val = new *string(value);
	status = yypush_parse(ps, myToken, &val, &loc);
	if(status != YYPUSH_MORE){	//nonzero for an error
		yypstate_delete(ps);
		return status;
	}
	return 0;
}

%}

%%
"and"				{if(push(AND, yytext) != 0){
					return 1;}
				}

"break"				{if(push(BREAK, yytext) != 0){
					return 1;}
				}

"def"				{if(push(DEF, yytext) != 0){
					return 1;}
				}

"elif"				{if(push(ELIF, yytext) != 0){
					return 1;}
				}

"else"				{if(push(ELSE, yytext) != 0){
					return 1;}
				}

"for"				{if(push(FOR, yytext) != 0){
					return 1;}
				}

"if"				{if(push(IF, yytext) != 0){
					return 1;}
				}

"not"				{if(push(NOT, yytext) != 0){
					return 1;}
				}

"or"				{if(push(OR, yytext) != 0){
					return 1;}
				}

"return"			{if(push(RETURN, yytext) != 0){
					return 1;}
				}

"while"				{if(push(WHILE, yytext) != 0){
					return 1;}
				}

"="				{if(push(ASSIGN, yytext) != 0){
					return 1;}
				}
				
"+"				{if(push(PLUS, yytext) != 0){
					return 1;}
				}

"-"				{if(push(MINUS, yytext) != 0){
					return 1;}
				}

"*"				{if(push(TIMES, yytext) != 0){
					return 1;}
				}

"/"				{if(push(DIVIDEDBY, yytext) != 0){
					return 1;}
				}

"=="				{if(push(EQ, yytext) != 0){
					return 1;}
				}

"!="				{if(push(NEQ, yytext) != 0){
					return 1;}
				}

">"				{if(push(GT, yytext) != 0){
					return 1;}
				}
				
">="				{if(push(GTE, yytext) != 0){
					return 1;}
				}

"<"				{if(push(LT, yytext) != 0){
					return 1;}
				}

"<="				{if(push(LTE, yytext) != 0){
					return 1;}
				}

"("				{if(push(LPAREN, yytext) != 0){
					return 1;}
				}

")"				{if(push(RPAREN, yytext) != 0){
					return 1;}
				}

","				{if(push(COMMA, yytext) != 0){
					return 1;}
				}

":"				{if(push(COLON, yytext) != 0){
					return 1;}
				}

[\n]				{if(push(NEWLINE, yytext) != 0){
					return 1;}
				}

"True"				{if(push(TRUE, yytext) != 0){
					return 1;}
				}

"False"				{if(push(FALSE, yytext) != 0){
					return 1;}
				}

[a-zA-Z][_a-zA-Z0-9]*		{if(push(IDENTIFIER, yytext) != 0){
					return 1;}
				}
			
[-]?[0-9]*\.[0-9]+		{if(push(FLOAT, yytext) != 0){
					return 1;}
				}		
				/*read as one or none negative, as many numbers escaped by a '.' followed by one or more numbers*/
[0]|[1-9][0-9]*			{if(push(INTEGER, yytext) != 0){
					return 1;}
				}
#.*$				{;}
^[ \t]*				{					//match all starting tabs to get length
				if(indents.empty() == true){		//if stack is empty push new yyleng
					indents.push(yyleng);
					if(push(INDENT, yytext) != 0){
						return 1;
					}
				}
				else if(yyleng == indents.top()){	//if stack is at same indent level do nothing
					;
				}
				else if(yyleng > indents.top()){	//if new length is greater then push onto stack
					indents.push(yyleng);
					if(push(INDENT, yytext) != 0){
						return 1;
					}	
				}
				else{					//if new length is less than...
					if(yytext[0] == '\t'){		//if new length does start with tab then pop one
						indents.pop();
						if(push(DEDENT, yytext) != 0){
							return 1;
						}
					}
					else{				//if new length doesn't then reject
						REJECT;
					}
				}
				}

^[^\t]$				{					//if line doesnt contain tabs
					while(indents.empty() == false){//pop off everything off stack
						indents.pop();
						if(push(DEDENT, yytext) != 0){
							return 1;
						}
					}
				
				}

				
<<EOF>>				{					//when EOF is reached pop off everything
					while(indents.empty() == false){
						indents.pop();
						if(push(DEDENT, yytext) != 0){
							return 1;
						}
						else{
							return 0;
						}
					}
					yyterminate();
				}
				
%%

int yywrap(){
	return 1;
}

