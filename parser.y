%{
#include "dsl_json_ast.h"
extern int yylex();
extern int yylineno;  // Declare yylineno (defined in the lexer)
void yyerror(const char *s);
ASTNode *ast_root = NULL;
%}

%union {
    char *str;
    double num;
    int boolean;
    ASTNode *node;
}

%token <str> STRING
%token <num> NUMBER
%token <boolean> BOOLEAN
%token NULL_LITERAL
%token TYPE PROPERTIES REQUIRED
%token '{' '}' '[' ']' ':' ','

%type <node> schema object array value property properties_list required_list

%start schema

%%

schema:
    '{' properties_list '}' { ast_root = $2; }
    ;

properties_list:
    /* Empty */ { $$ = NULL; }
    | property { $$ = $1; }
    | property ',' properties_list { $1->next = $3; $$ = $1; }
    ;

property:
    STRING ':' value {
        ASTNode *node = create_node("property", $1);
        node->value.child = $3;
        $$ = node;
    }
    ;

value:
    STRING { $$ = create_node("string", NULL); $$->value.str = $1; }
    | NUMBER { $$ = create_node("number", NULL); $$->value.num = $1; }
    | BOOLEAN { $$ = create_node("boolean", NULL); $$->value.boolean = $1; }
    | NULL_LITERAL { $$ = create_node("null", NULL); }
    | object { $$ = $1; }
    | array { $$ = $1; }
    ;

object:
    '{' properties_list '}' {
        ASTNode *node = create_node("object", NULL);
        node->value.child = $2;
        $$ = node;
    }
    ;

array:
    '[' required_list ']' {
        ASTNode *node = create_node("array", NULL);
        node->value.child = $2;
        $$ = node;
    }
    ;

required_list:
    /* Empty */ { $$ = NULL; }
    | STRING { $$ = create_node("required", $1); }
    | STRING ',' required_list { $3->next = create_node("required", $1); $$ = $3; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Syntax error at line %d: %s\n", yylineno, s);
    exit(1);
}

int main() {
    yyparse();
    printf("Intermediate Representation (AST):\n");
    print_ast(ast_root, 0);
    free_ast(ast_root);
    return 0;
}

// AST Functions (now in header)
