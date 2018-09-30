#include "tree.h"

int main() {

    valor_lexico_t* arr[21];
    tree_node_t* nodes[21];

    arr[0] = __construct_valor_lexico(0, AST_TYPE_PROGRAM_START, NULL);
    arr[1] = __construct_valor_lexico(1, AST_TYPE_WHILE_DO, NULL);
    arr[2] = __construct_valor_lexico(1, AST_TYPE_NE, NULL);
    arr[3] = __construct_valor_lexico(1, AST_TYPE_IDENTIFICATOR, "var_aux");
    arr[4] = __construct_valor_lexico(1, AST_TYPE_LITERAL_INT, "0");
    arr[5] = __construct_valor_lexico(2, AST_TYPE_IF_ELSE, NULL);
    arr[6] = __construct_valor_lexico(2, AST_TYPE_GR, NULL);
    arr[7] = __construct_valor_lexico(2, AST_TYPE_IDENTIFICATOR, "var");
    arr[8] = __construct_valor_lexico(2, AST_TYPE_IDENTIFICATOR, "var_aux");
    arr[9] = __construct_valor_lexico(3, AST_TYPE_ATTRIBUTION, NULL);
    arr[10] = __construct_valor_lexico(3, AST_TYPE_IDENTIFICATOR, "var");
    arr[11] = __construct_valor_lexico(3, AST_TYPE_SUB, NULL);
    arr[12] = __construct_valor_lexico(3, AST_TYPE_IDENTIFICATOR, "var");
    arr[13] = __construct_valor_lexico(3, AST_TYPE_IDENTIFICATOR, "var_aux");
    arr[14] = __construct_valor_lexico(5, AST_TYPE_ATTRIBUTION, NULL);
    arr[15] = __construct_valor_lexico(5, AST_TYPE_IDENTIFICATOR, "var_aux");
    arr[16] = __construct_valor_lexico(5, AST_TYPE_SUB, NULL);
    arr[17] = __construct_valor_lexico(5, AST_TYPE_IDENTIFICATOR, "var_aux");
    arr[18] = __construct_valor_lexico(5, AST_TYPE_IDENTIFICATOR, "var");
    arr[19] = __construct_valor_lexico(6, AST_TYPE_RETURN, NULL);
    arr[20] = __construct_valor_lexico(6, AST_TYPE_IDENTIFICATOR, "var");


    tree_node_t* head = make_tree();
    head->value = arr[0];
    nodes[0] = head;        // for consitency

    for(int i = 1; i < 21; i++) {
        nodes[i] = make_node(arr[i]);
    }

    insert_child(head, nodes[1]);
    insert_child(head, nodes[19]);
    insert_child(nodes[1], nodes[2]);
    insert_child(nodes[1], nodes[5]);
    insert_child(nodes[2], nodes[3]);
    insert_child(nodes[2], nodes[4]);
    insert_child(nodes[5], nodes[6]);
    insert_child(nodes[5], nodes[9]);
    insert_child(nodes[5], nodes[14]);
    insert_child(nodes[6], nodes[7]);
    insert_child(nodes[6], nodes[8]);
    insert_child(nodes[9], nodes[10]);
    insert_child(nodes[9], nodes[11]);
    insert_child(nodes[11], nodes[12]);
    insert_child(nodes[11], nodes[13]);
    insert_child(nodes[14], nodes[15]);
    insert_child(nodes[14], nodes[16]);
    insert_child(nodes[16], nodes[17]);
    insert_child(nodes[16], nodes[18]);
    insert_child(nodes[19], nodes[20]);


    print_DFS(head);
    clean_tree_DFS(head);

    // for(int i = 1; i < 21; i++) {
    //     free(nodes[i]);
    // }

    return 0;
}