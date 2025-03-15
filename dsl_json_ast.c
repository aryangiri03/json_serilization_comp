#include "dsl_json_ast.h"

ASTNode* create_node(char *type, char *key) {
    ASTNode *node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = strdup(type);
    node->key = key ? strdup(key) : NULL;
    node->next = NULL;
    return node;
}

void print_ast(ASTNode *node, int indent) {
    if (!node) return;
    for (int i = 0; i < indent; i++) printf("  ");
    if (node->key) printf("%s: ", node->key);
    printf("%s", node->type);
    if (strcmp(node->type, "string") == 0) printf(" (%s)", node->value.str);
    else if (strcmp(node->type, "number") == 0) printf(" (%f)", node->value.num);
    else if (strcmp(node->type, "boolean") == 0) printf(" (%s)", node->value.boolean ? "true" : "false");
    printf("\n");
    print_ast(node->value.child, indent + 1);
    print_ast(node->next, indent);
}

void free_ast(ASTNode *node) {
    if (!node) return;
    free_ast(node->value.child);
    free_ast(node->next);
    free(node->type);
    if (node->key) free(node->key);
    free(node);
}
