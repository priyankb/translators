%{
#include <stdlib.h>
#include <iostream>
#include <set>
#include <string>
#include <ctype.h>
#include <vector>
#include "parser.hpp"

void yyerror(YYLTYPE* loc, char*);
extern int yylex(void);

using namespace std;
std::set<string> myset;		//set of identifiers
std::set<string>::iterator it;
std::vector<string*> lines;	//vector of translated lines of code

string* assignmentHandler(string* id, string* expr){
	string* line = new string();
	it = myset.find(*id);
	if(it == myset.end()){
		myset.insert(*id);
		if(*expr == "true"){
			*line = "double " + *id + " = 1.0;";
		}
		else if(*expr == "false"){
			*line = "double " + *id + " = 0.0;";
		}
		else{
			*line = "double " + *id + " = " + *expr + ";";
		}
	}
	else{
		if(*expr == "true"){
			*line = *id + " = 1.0;";
		}
		else if(*expr == "false"){
			*line = *id + " = 0.0;";
		}
		else{
			*line = *id + " = " + *expr + ";";
		}
	}
	
	lines.push_back(line);
	return line;
}
string* parenHandler(string* l, string* expr, string* r){
	string* line = new string();
	*line = '(' + *expr + ')';
	return line;
}
string* operationHandler(string* x, string* op, string* y){
	string* result = new string();
	if(*op == "+"){	
		(*result).append(*x);
		(*result).append(" + ");
		(*result).append(*y);
	}
	else if(*op == "-"){
		(*result).append(*x);
		(*result).append(" - ");
		(*result).append(*y);
	}
	else if(*op == "*"){
		(*result).append(*x);
		(*result).append(" * ");
		(*result).append(*y);
	}
	else if(*op == "/"){
		(*result).append(*x);
		(*result).append(" / ");
		(*result).append(*y);
	}
	return result;
}
string* exprNumHandler(string* num){
	string* line = new string();
	*line  = *num;
	return line;
}
string* exprBoolHandler(string* boolean){
	string* line = new string();
	if(*boolean == "True"){
		*line = "true";
	}
	else{
		*line = "false";
	}
	return line;
}
string* identifierHandler(string* id){
	it = myset.find(*id);
	if(it == myset.end()){
		cout << "Error" << endl;
	}
	else{
		myset.insert(*id);
	}
	return id;	
}

string* whileHandler(string* cond1, string* cond2, string comparator){
	string* whileResult = new string();
	
	if(comparator == "!"){
		*whileResult = "while(" + comparator + *cond1 + ")";
	}
	else if(comparator == " && "){
		*whileResult = "while(" + *cond1 + comparator + *cond2 + ")";
	}
	else if(comparator == " || "){
		*whileResult = "while(" + *cond1 + comparator + *cond2 + ")";
	}
	else if(comparator == " < "){
		*whileResult = "while(" + *cond1 + comparator + *cond2 + ")";
	}
	else if(comparator == " > "){
		*whileResult = "while(" + *cond1 + comparator + *cond2 + ")";
	}
	else if(comparator == " == "){
		*whileResult = "while(" + *cond1 + comparator + *cond2 + ")";
	}
	else if(comparator == " != "){
		*whileResult = "while(" + *cond1 + comparator + *cond2 + ")";
	}
	else if(comparator == " <= "){
		*whileResult = "while(" + *cond1 + comparator + *cond2 + ")";
	}
	else if(comparator == " >= "){
		*whileResult = "while(" + *cond1 + comparator + *cond2 + ")";
	}

	lines.push_back(whileResult);
	return whileResult;
}
string* ifHandler(string* cond1, string* cond2, string comparator){
	string *ifResult = new string();
	
	if(comparator == "!"){
		*ifResult = "if(" + comparator + *cond1 + "){\n";
	}
	else if(comparator == " && "){
		*ifResult = "if(" + *cond1 + comparator + *cond2 + "){\n";
	}
	else if(comparator == " || "){
		*ifResult = "if(" + *cond1 + comparator + *cond2 + "){\n";
	}
	else if(comparator == " < "){
		*ifResult = "if(" + *cond1 + comparator + *cond2 + "){\n";
	}
	else if(comparator == " > "){
		*ifResult = "if(" + *cond1 + comparator + *cond2 + "){\n";
	}
	else if(comparator == " == "){
		*ifResult = "if(" + *cond1 + comparator + *cond2 + "){\n";
	}
	else if(comparator == " != "){
		*ifResult = "if(" + *cond1 + comparator + *cond2 + "){\n";
	}
	else if(comparator == " <= "){
		*ifResult = "if(" + *cond1 + comparator + *cond2 + "){\n";
	}
	else if(comparator == " >= "){
		*ifResult = "if(" + *cond1 + comparator + *cond2 + "){\n";
	}

	lines.push_back(ifResult);
	return ifResult;
}
string* exprWhileHandler(string* expr){
	string* line = new string();
	*line = "while(" + *expr + "){\n";
	lines.push_back(line);
	return line;
}
string* exprIfHandler(string* expr){
	string* line = new string();
	*line = "if(" + *expr + "){\n";
	lines.push_back(line);
	return line;
}
string* breakHandler(){
	string *line = new string();
	*line = "break;";
	lines.push_back(line);
	return line;
}
string* elseifHandler(string* ifText){
	string* elseifResult = new string();
	*elseifResult = "else if(" + *ifText + "){\n";
	lines.push_back(elseifResult);
	return elseifResult;
}
string* elseHandler(){
	string* elseResult = new string();
	*elseResult = "else{ \n";
	lines.push_back(elseResult);
	return elseResult;
}
string* closeBraceHandler(){
	string* closeBrace = new string();
	*closeBrace = "}";
	lines.push_back(closeBrace);
	return closeBrace;
}
string* pushNewline(){
	string* newLine = new string();
	*newLine = "\n";
	lines.push_back(newLine);
	return newLine;
}
void yyerror(YYLTYPE* loc, const char* err){
	cout << "Error on line: " << loc->first_line;
	cout << " " << err << "\n";
}
%}

%define api.pure full
%define api.push-pull push
%define api.value.type{std::string*}
%define parse.error verbose
%locations

%start input
%token AND BREAK DEF ELIF ELSE FOR IF NOT OR RETURN WHILE ASSIGN PLUS
%token MINUS TIMES DIVIDEDBY EQ NEQ GT GTE LT LTE LPAREN RPAREN COMMA
%token COLON NEWLINE TRUE FALSE IDENTIFIER FLOAT INTEGER INDENT DEDENT


%left OR
%left AND
%left LT GT EQ NEQ LTE GTE
%left PLUS MINUS
%left TIMES DIVIDEDBY
%right NOT

%%
input:
     input line
|    line	
;

line:
     assign	{$$ = $1;}
|    if		{$$ = $1;}
|    While	{$$ = $1;}
|    break	{$$ = $1;}
|    NEWLINE 	{$$ = pushNewline();}
;
nums:
     INTEGER	{$$ = $1;}
|    FLOAT	{$$ = $1;}
;
booleans:
     TRUE	{$$ = $1;}
|    FALSE	{$$ = $1;}
;
assign:
     IDENTIFIER ASSIGN expr NEWLINE	{$$ = assignmentHandler($1, $3);}
;
expr: //identifiers
     nums			{$$ = exprNumHandler($1);}	
|    booleans			{$$ = exprBoolHandler($1);}
|    IDENTIFIER			{$$ = identifierHandler($1);}
|    LPAREN expr RPAREN		{$$ = parenHandler($1, $2, $3);}
|    expr PLUS expr		{$$ = operationHandler($1, $2, $3);}
|    expr MINUS expr		{$$ = operationHandler($1, $2, $3);}
|    expr DIVIDEDBY expr	{$$ = operationHandler($1, $2, $3);}
|    expr TIMES expr		{$$ = operationHandler($1, $2, $3);}
;

if:
     IF ifCond COLON NEWLINE INDENT input DEDENT elif else	{$$ = $2;}
;

elif:
     %empty 							{$$ = NULL;}
|    elif ELIF ifCond COLON NEWLINE INDENT input DEDENT		{$$ = elseifHandler($3);}
;

else:
     %empty 							{$$ = NULL;}
|    ELSE COLON NEWLINE INDENT input DEDENT			{$$ = elseHandler();}
;

ifCond:
     expr			{$$ = exprIfHandler($1);}
|    NOT ifCond			{$$ = ifHandler($2, NULL, "!");}
|    ifCond AND ifCond		{$$ = ifHandler($1, $3, " && ");}
|    ifCond OR ifCond		{$$ = ifHandler($1, $3, " || ");}
|    ifCond LT ifCond		{$$ = ifHandler($1, $3, " < ");}
|    ifCond GT ifCond		{$$ = ifHandler($1, $3, " > ");}
|    ifCond EQ ifCond		{$$ = ifHandler($1, $3, " == ");}
|    ifCond NEQ ifCond		{$$ = ifHandler($1, $3, " != ");}
|    ifCond LTE ifCond		{$$ = ifHandler($1, $3, " <= ");}
|    ifCond GTE ifCond		{$$ = ifHandler($1, $3, " >= ");}
;

While:
     WHILE whileCond COLON NEWLINE INDENT input DEDENT	{$$ = $2;}
;

whileCond:
     expr			{$$ = exprWhileHandler($1);}
|    NOT whileCond		{$$ = whileHandler($1, NULL, "!");}
|    whileCond AND whileCond 	{$$ = whileHandler($1, $3, " && ");}
|    whileCond OR whileCond	{$$ = whileHandler($1, $3, " || ");}
|    whileCond LT whileCond	{$$ = whileHandler($1, $3, " < ");}
|    whileCond GT whileCond	{$$ = whileHandler($1, $3, " > ");}
|    whileCond EQ whileCond	{$$ = whileHandler($1, $3, " == ");}
|    whileCond NEQ whileCond	{$$ = whileHandler($1, $3, " != ");}
|    whileCond LTE whileCond	{$$ = whileHandler($1, $3, " <= ");}
|    whileCond GTE whileCond	{$$ = whileHandler($1, $3, " >= ");}
;

break:
     BREAK NEWLINE		{$$ = breakHandler();}
;





%%
