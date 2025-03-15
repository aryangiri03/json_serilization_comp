%{
#include "dsl_json_ast.h"
#include "dsl_json_parser.tab.h"
extern int yylineno;
%}

%option noyywrap
%option yylineno

WHITESPACE      [ \t\r\n]
STRING_LITERAL  \"([^\\\"]|\\.)*\"
NUMBER_LITERAL  -?(0|[1-9][0-9]*)(\.[0-9]+)?([eE][+-]?[0-9]+)?
BOOLEAN         true|false
NULL            null
TYPE            "type"
PROPERTIES      "properties"
REQUIRED        "required"

%%

{WHITESPACE}    { /* Ignore */ }
{STRING_LITERAL} {
    // Manual string copy (replaces strndup)
    int len = yyleng - 2;
    yylval.str = (char*)malloc(len + 1);
    strncpy(yylval.str, yytext + 1, len);
    yylval.str[len] = '\0';
    return STRING;
}
{NUMBER_LITERAL} { yylval.num = atof(yytext); return NUMBER; }
{BOOLEAN}       { yylval.boolean = (strcmp(yytext, "true") == 0); return BOOLEAN; }
{NULL}          { return NULL_LITERAL; }
{TYPE}          { return TYPE; }
{PROPERTIES}    { return PROPERTIES; }
{REQUIRED}      { return REQUIRED; }
"{"             { return '{'; }
"}"             { return '}'; }
"["             { return '['; }
"]"             { return ']'; }
":"             { return ':'; }
","             { return ','; }
.               { 
    fprintf(stderr, "Lexical error at line %d: Invalid character '%s'\n", yylineno, yytext);
    exit(1);
}

%%
