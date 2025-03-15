#ifndef DSL_JSON_AST_H
#define DSL_JSON_AST_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct ASTNode {
    char *type;
    char *key;
    union {
        double num;
        char *str;
        int boolean;
        struct ASTNode *child;
    } value;
    struct ASTNode *next;
} ASTNode;

ASTNode* create_node(char *type, char *key);
void print_ast(ASTNode *node, int indent);
void free_ast(ASTNode *node);

#endif
