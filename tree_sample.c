#include "tree.h"

int main() {

    int arr[20];
    tree_node_t* nodes[20];

    tree_node_t* head = make_tree();
    arr[0] = 0;
    head->value = &arr[0];
    nodes[0] = head;        // for consitency

    for(int i = 1; i < 20; i++) {
        arr[i] = i;
        nodes[i] = make_node(&arr[i]);
    }

    insert_child(head, nodes[1]);
    insert_child(head, nodes[2]);
    insert_child(head, nodes[3]);
    insert_child(head, nodes[4]);

    insert_child(nodes[1], nodes[5]);
    insert_child(nodes[1], nodes[6]);
    insert_child(nodes[1], nodes[7]);

    insert_child(nodes[5], nodes[8]);
    insert_child(nodes[5], nodes[9]);

    insert_child(nodes[7], nodes[10]);
    insert_child(nodes[10], nodes[11]);
    insert_child(nodes[11], nodes[12]);

    insert_child(nodes[3], nodes[16]);
    insert_child(nodes[4], nodes[17]);

    insert_child(nodes[2], nodes[13]);
    insert_child(nodes[2], nodes[14]);

    insert_child(nodes[14], nodes[15]);

    print_BFS(head);
    printf("\n-----\n");
    print_DFS(head);
}