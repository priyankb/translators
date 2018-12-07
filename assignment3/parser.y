%{
#include <stdlib.h>
#include <iostream>
#include <set>
#include <string>
#include <ctype.h>
#include <vector>
using namespace std;	//header files defined after namespace
#include "parser.hpp"
#include "node.hpp"

void yyerror(char*);
extern int yylex(void);

std::set<string*> myset;
std::set<string*>::iterator it;
std::vector<string*> lines;
struct node* head_node = new node("Block");

struct node* assignmentHandler(string* id, struct node* expr){
	struct node* identifier_node = new node("Identifier: " + *id);
	struct node* assignment_node = new node("Assignment");
	
	assignment_node->type = 1;	//signifies assignment node
	assignment_node->left = identifier_node;
	assignment_node->right = expr;
	return assignment_node;
}
struct node* operationHandler(struct node* x, string* op, struct node* y){
	string* result;
	struct node* op_node;
	if(*op == "+"){
		op_node = new node("PLUS");
	}
	else if(*op == "-"){
		op_node = new node("MINUS");
	}
	else if(*op == "*"){
		op_node = new node("TIMES");
	}
	else if(*op == "/"){
		op_node = new node("DIVIDEDBY");
	}
	op_node->left = x;
	op_node->right = y;
	return op_node;
}
struct node* exprNumHandler(string* num){
	struct node* new_node = new node("Float: " + *num);
	return new_node;
}
struct node* exprBoolHandler(string* boolean){
	struct node* new_node;
	if(*boolean == "TRUE"){
		new_node = new node("Boolean: 1");
	}
	else{
		new_node = new node("Boolean: 0");
	}
	return new_node;
}
struct node* identifierHandler(string* id){
	struct node* new_node = new node("Identifier: " + *id);
	return new_node;
}
struct node* whileHandler(struct node* cond1, struct node* cond2, string comparator){
	struct node* new_node;	
	if(comparator == "!"){
		struct node* NOT_node = new node("!");
		new_node = new node(NOT_node->val + "(" + cond1->val + ")");
		new_node->left = NOT_node;
		new_node->right = cond1;
		//aggregated
	}
	else if(comparator == " && "){
		new_node = new node(" && "); 	//not aggregated
		new_node->left = cond1;
		new_node->right = cond2;
	}
	else if(comparator == " || "){
		new_node = new node(" || ");
		new_node->left = cond1;
		new_node->right = cond2;
	}
	else if(comparator == " < "){
		new_node = new node(" < ");
		new_node->left = cond1;
		new_node->right = cond2;
	}
	else if(comparator == " > "){
		new_node = new node(" > ");
		new_node->left = cond1;
		new_node->right = cond2;
	}
	else if(comparator == " == "){
		new_node = new node(" == ");
		new_node->left = cond1;
		new_node->right = cond2;
	}
	else if(comparator == " != "){
		new_node = new node(" != ");
		new_node->left = cond1;
		new_node->right = cond2;
	}
	else if(comparator == " <= "){
		new_node = new node(" <= ");
		new_node->left = cond1;
		new_node->right = cond2;
	}
	else if(comparator == " >= "){
		new_node = new node(" >= ");
		new_node->left = cond1;
		new_node->right = cond2;
	}

	return new_node;
}
struct node* simpleWhileHandler(struct node* expr){
	struct node* while_node = new node("while");
	struct node* parent_while_node = new node(while_node->val + "(" + expr->val + ")");
	
	parent_while_node->type = 3;	//signifies while node
	parent_while_node->left = while_node;
	parent_while_node->right = expr;
	
	return parent_while_node;
	
}
struct node* simpleIfHandler(struct node* expr){
	struct node* if_node = new node("if");
	struct node* parent_if_node = new node(if_node->val + "(" + expr->val + ")");
	
	parent_if_node->type = 2;	//signifies if node
	parent_if_node->left = if_node;
	parent_if_node->right = expr;
	
	return parent_if_node;
}
struct node* ifHandler(struct node* cond1, struct node* cond2, string comparator){
	struct node* new_node;	
	if(comparator == "!"){
		struct node* NOT_node = new node("!");
		new_node = new node(NOT_node->val + "(" + cond1->val + ")");
		new_node->left = NOT_node;
		new_node->right = cond1;
	}
	else if(comparator == " && "){
		new_node = new node("AND");
		new_node->left = cond1;
		new_node->right = cond2;
	}
	else if(comparator == " || "){
		new_node = new node("OR");
		new_node->left = cond1;
		new_node->right = cond2;
	}
	else if(comparator == " < "){
		new_node = new node("LT");
		new_node->left = cond1;
		new_node->right = cond2;
	}
	else if(comparator == " > "){
		new_node = new node("GT");
		new_node->left = cond1;
		new_node->right = cond2;
	}
	else if(comparator == " == "){
		new_node = new node("EQ");
		new_node->left = cond1;
		new_node->right = cond2;
	}
	else if(comparator == " != "){
		new_node = new node("NEQ");
		new_node->left = cond1;
		new_node->right = cond2;
	}
	else if(comparator == " <= "){\
		new_node = new node("LTE");
		new_node->left = cond1;
		new_node->right = cond2;
	}
	else if(comparator == " >= "){
		new_node = new node("GTE");
		new_node->left = cond1;
		new_node->right = cond2;
	}

	return new_node;
}
struct node* breakHandler(){
	struct node* breakNode = new node("break");
	return breakNode;
}
struct node* dedentHandler(){
	struct node* dedent_node = new node("\n");	//unnecessary as dedents don't need seperate nodes	
	return dedent_node;
}
struct node* elseifHandler(struct node* ifNode){
	string* elseifResult;
	struct node* elseifNode = new node("else if");
	elseifNode->left = ifNode;
	return elseifNode;
}
struct node* elseHandler(struct node* elseNode){
	string* elseResult;
	struct node* higherElseNode = new node("else");
	higherElseNode->left = elseNode;
	return higherElseNode;
}
struct node* overallIfHandler(struct node* ifCond, struct node* lineNode, struct node* secondIfNode){
	struct node* lowerIfNode = new node(ifCond->val + "{" + lineNode->val + "}");	//brackets not needed for format
	struct node* higherIfNode = new node(lowerIfNode->val + secondIfNode->val);
	
	lowerIfNode->left = ifCond;
	lowerIfNode->right = lineNode;
	
	higherIfNode->left = lowerIfNode;
	higherIfNode->right = secondIfNode;
	
	return higherIfNode;

}
struct node* overallWhileHandler(struct node* whileCond, struct node* lineNode){
	struct node* while_node = new node(whileCond->val + "{" + lineNode->val + "}");
	while_node->left = whileCond;
	while_node->right = lineNode;

	return while_node;

}
struct node* assignHeadNode(struct node* line){
	head_node->left = line;
	return head_node;
}
void yyerror(const char* err){
	cout << "Error: " << err << endl;
}
%}

%union{
	string* text;
	struct node* block;
}

%define api.pure full
%define api.push-pull push

%start input
%token <text> IDENTIFIER FLOAT INTEGER TRUE FALSE PLUS MINUS TIMES DIVIDEDBY
%token <block> AND BREAK DEF ELIF ELSE FOR IF NOT OR RETURN WHILE
%token <block> ASSIGN EQ NEQ GT GTE
%token <block> LT LTE LPAREN RPAREN COMMA COLON NEWLINE INDENT DEDENT
%type <text> nums booleans
%type <block> input line assign expr if secondaryIf ifCond
%type <block> While whileCond break

%left OR
%left AND
%left LT GT EQ NEQ LTE GTE
%left PLUS MINUS
%left TIMES DIVIDEDBY
%right NOT

%%
input:
     input line {$$ = assignHeadNode($2);}
|    line	
;

line:
     assign	{$$ = $1;}
|    if		{$$ = $1;}
|    While	{$$ = $1;}
|    break	{$$ = $1;}
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
expr:
     nums			{$$ = exprNumHandler($1);}	
|    booleans			{$$ = exprBoolHandler($1);}
|    IDENTIFIER			{$$ = identifierHandler($1);}
|    LPAREN expr RPAREN		{$$ = $2;}
|    expr PLUS expr		{$$ = operationHandler($1, $2, $3);}	
|    expr MINUS expr		{$$ = operationHandler($1, $2, $3);}
|    expr DIVIDEDBY expr	{$$ = operationHandler($1, $2, $3);}
|    expr TIMES expr		{$$ = operationHandler($1, $2, $3);}
;

if:	//new if productions implemented in assign2 needed to be translated (elif, else)
     IF ifCond COLON NEWLINE INDENT line secondaryIf	{$$ = overallIfHandler($2, $6, $7);}
;

secondaryIf:						//line needed for else-if block?
	   DEDENT		{$$ = dedentHandler();}
|	   DEDENT ELSE if	{$$ = elseifHandler($3);}
|	   DEDENT ELSE COLON NEWLINE INDENT line DEDENT	{$$ = elseHandler($6);}
;

ifCond:	
     expr			{$$ = simpleIfHandler($1);}
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
     WHILE whileCond COLON NEWLINE INDENT line DEDENT	{$$ = overallWhileHandler($2, $6);}
;

whileCond:
     expr			{$$ = simpleWhileHandler($1);}
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
