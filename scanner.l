%option no yywrap

%{
#include "scanner.h"
#include <stack>

std::stack<int> indents;
%}

%%
"and"				printf("%s \t %s \n", yytext, AND);
"break"				printf("%s \t %s \n", yytext, BREAK);
"def"				printf("%s \t %s \n", yytext, DEF);
"elif"				printf("%s \t %s \n", yytext, ELIF);
"else"				printf("%s \t %s \n", yytext, ELSE);
"for"				printf("%s \t %s \n", yytext, FOR);
"if"				printf("%s \t %s \n", yytext, IF);
"not"				printf("%s, \t %s \n", yytext, NOT);
"or"				printf("%s \t %s \n", yytext, OR);
"return"			printf("%s \t %s \n", yytext, RETURN);
"while"				printf("%s \t %s \n", yytext, WHILE);
"="				printf("%s \t %s \n", yytext, ASSIGN);
"+"				printf("%s \t %s \n", yytext, PLUS);
"-"				printf("%s \t %s \n", yytext, MINUS);
"*"				printf("%s \t %s \n", yytext, TIMES);
"/"				printf("%s \t %s \n", yytext, DIVIDEDBY);
"=="				printf("%s \t %s \n", yytext, EQ);
"!="				printf("%s \t %s \n", yytext, NEQ);
">"				printf("%s \t %s \n", yytext, GT);
">="				printf("%s \t %s \n", yytext, GTE);
"<"				printf("%s \t %s \n", yytext, LT);
"<="				printf("%s \t %s \n", yytext, LTE);
"("				printf("%s \t %s \n", yytext, LPAREN);
")"				printf("%s \t %s \n", yytext, RPAREN);
","				printf("%s \t %s \n", yytext, COMMA);
":"				printf("%s \t %s \n", yytext, COLON);
^[\n]				;
[\n]				printf("%s \t %s \n", yytext, NEWLINE);
"True"				printf("%s \t %s \n", "true", BOOLEAN);
"False"				printf("%s \t %s \n", "false", BOOLEAN);

[a-zA-Z][_a-zA-Z0-9]*		printf("%s \t %s \n", yytext, IDENTIFIER);
[-]?[0-9]*\.[0-9]+		printf("%s \t %s \n", yytext, FLOAT);	//read as one or none negative, as many numbers escaped by a '.' followed by one or more numbers
[0]|[1-9][0-9]*			printf("%s \t %s \n", yytext, INTEGER);
#.*$				printf("COMMENTS");
^[ \t]*				{					//match all starting tabs to get length
				if(indents.empty() == true){		//if stack is empty push new yyleng
					indents.push(yyleng);
					printf("%s \t %s \n", yytext, INDENT);
				}
				else if(yyleng == indents.top()){	//if stack is at same indent level do nothing
					;
				}
				else if(yyleng > indents.top()){	//if new length is greater then push onto stack
					indents.push(yyleng);
					printf("%s \t %s \n", yytext, INDENT);	
				}
				else{					//if new length is less than...
					if(yytext[0] == '\t'){		//if new length does start with tab then pop one
						indents.pop();
						printf("%s \t %s \n", yytext, DEDENT);
					}
					else{				//if new length doesn't then reject
						REJECT;
					}
				}
				}

^[^\t]$				{					//if line doesnt contain tabs
					while(indents.empty() == false){//pop off everything off stack
						indents.pop();
						printf("%s \t %s \n", yytext, DEDENT);
					}
				
				}

				
<<EOF>>				{					//when EOF is reached pop off everything
					while(indents.empty() == false){
						indents.pop();
						printf("%s \t %s \n", yytext, DEDENT);
					}
					yyterminate();
				}
				
%%

int yywrap(){
	return 1;
}

