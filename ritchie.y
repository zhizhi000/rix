%{
#include <stdio.h>
#include <stdlib.h>
#include "ritc.h"
#include "errors.h"

#define YYPARSE_PARAM scanner
#define YYLEX_PARAM   scanner

%}

%glr-parser
%locations
%define api.pure //full
%define parse.error verbose

// Bison fundamentally works by asking flex to get the next token, which it
// returns as an object of type "yystype".  But tokens could be of any
// arbitrary data type!  So we deal with that in Bison by defining a C union
// holding each of the types of tokens that Flex could return, and have Bison
// use that union instead of "int" for the definition of "yystype":
%union {
	int ival;
	float fval;
	char *sval;
}

// define the constant-string tokens:
%token ENDOFLINE
%token ENDOFFILE 0 "end of file"

// define the "terminal symbol" token types I'm going to use (in CAPS
// by convention), and associate each with a field of the union:
%token <ival> INT
%token <fval> FLOAT
%token <sval> IDENT
%token <sval> VERB
%token <sval> TYPE
%token <sval> MATH_OP
%token <sval> ASSIGNMENT 
%token <sval> LPAREN
%token <sval> RPAREN

%type <sval> expression
%type <sval> objects
%type <sval> object
%type <sval> subject
%type <sval> verb
%type <ival> int_expression
%type <fval> float_expression

%{
void yyerror(YYLTYPE *locp, const char* msg);
//void yyerror(const char* msg);
%}
%%
%start ritchie;
ritchie:
	statements
	| ENDOFFILE  { handleEOF(); }
	;
statements:
  simple_statement
  | statements simple_statement
  ;
simple_statement:
  ENDOFLINE              { handleEOL();}
  | statement ENDOFLINE  { handleEOL();}
  ;
statement:
  expression
  ;
expression:
  subject verb objects
  | subject verb
  | verb objects
  | verb
  ;
objects: 
  object
  | objects object
/*  | objects "," object   /* This hasn't been handled properly yet. */
  ;
object:
  int_expression { $$ = objectInt($1); }
  | float_expression { $$ = objectFloat($1); }
  | IDENT { $$ = objectIdent($1); }
  | LPAREN expression RPAREN
  | verb object
  ;
subject:
  IDENT { $$ = subjectIdent($1); }
  ;
verb:
  VERB { $$ = verbIdent($1); }
  | ASSIGNMENT { $$ = verbAssignment($1); }
  | MATH_OP { $$ = verbMathOp($1); }
  ;
int_expression:
  int_expression MATH_OP INT { $$ = simplifyInt($1, $2, $3); }
  | INT MATH_OP INT          { $$ = simplifyInt($1, $2, $3); }
  ;
float_expression:
    float_expression MATH_OP FLOAT { $$ = simplifyFloat($1, $2, $3); }
  | float_expression MATH_OP INT   { $$ = simplifyFloat($1, $2, $3); }
  | int_expression MATH_OP FLOAT   { $$ = simplifyFloat($1, $2, $3); }
  | FLOAT MATH_OP INT   { $$ = simplifyFloat($1, $2, $3); }
  | INT MATH_OP FLOAT   { $$ = simplifyFloat($1, $2, $3); }
  | FLOAT MATH_OP FLOAT { $$ = simplifyFloat($1, $2, $3); }
  ;
%%

//void yyerror(char const *msg) {
void yyerror(YYLTYPE *locp, const char* msg) {
  char errorMsg[256];
  snprintf(errorMsg, 256, "%s\n", msg);
  criticalError(ERROR_ParseError, errorMsg);
	// might as well halt now:
	exit(-1);
}