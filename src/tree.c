#include "tree.h"

tree_node_t *make_tree() {
  return make_node(NULL);
}

tree_node_t *make_node(void *value) {

  tree_node_t *new_node = (tree_node_t *)malloc(sizeof(tree_node_t));

  if (!new_node)
    kill("Couldnt allocate new node");

  new_node->value = value;
  new_node->childAmount = 0;
  new_node->first_child = NULL;
  new_node->last_child = NULL;
  new_node->brother_next = NULL;
  new_node->brother_prev = NULL;

  return new_node;
}

tree_node_t *make_ast_node(valor_lexico_t* valor_lexico) {
  return make_node(valor_lexico);
}

tree_node_t *insert_child(tree_node_t *father, tree_node_t *children) {

  if(father == NULL) {
    kill("You can't insert on NULL.\n");
  }

  if(children == NULL) {
    kill("You can't insert NULL. You must treat it yourself first\n");
  }

  tree_node_t *current_son = father->first_child;

  if(!current_son) {
    father->first_child = children;
  } else {
    for (int i = 0; i < father->childAmount - 1; ++i) {
      current_son = current_son->brother_next;
    }
    current_son->brother_next = children;
    current_son->brother_next->brother_prev = current_son;
  }

  father->last_child = children;
  father->childAmount++;

  return father;
}

void print_BFS(tree_node_t *head) {
  queue_t *q = create_queue();
  tree_node_t *current_son;

  queue_push(q, head);
  while(!queue_is_empty(q)) {
    queue_node_t* _node = queue_pop(q);
    tree_node_t* node = _node->value;
    print_valor_lexico((valor_lexico_t*)node->value);
    current_son = node->first_child;
    while(current_son) {
      queue_push(q, current_son);
      current_son = current_son->brother_next;
    }
    free(_node);
  }
  clean_queue(q);
}

void print_DFS(tree_node_t *head) {
  stack_t *s = create_stack();
  tree_node_t *current_son;

  stack_push(s, head);
  while(!stack_is_empty(s)) {
    stack_node_t* _node = stack_pop(s);
    tree_node_t* node = _node->value;
    print_valor_lexico((valor_lexico_t*)node->value);
    current_son = node->last_child;
    while(current_son) {
      stack_push(s, current_son);
      current_son = current_son->brother_prev;
    }
    free(_node);
  }
  clean_stack(s);
}

void clean_tree_DFS(tree_node_t *head) {
  stack_t *s = create_stack();
  tree_node_t *current_son;

  stack_push(s, head);
  while(!stack_is_empty(s)) {
    stack_node_t* _node = stack_pop(s);
    tree_node_t* node = _node->value;
    current_son = node->last_child;
    while(current_son) {
      stack_push(s, current_son);
      current_son = current_son -> brother_prev;
    }
    free(_node);
    free(node->value);
    free(node);
  }
  clean_stack(s);
}

void descompila(tree_node_t *head) {
  valor_lexico_t* value = head->value;
  print_fancy(value, NULL);

}


void print_fancy(valor_lexico_t* value, tree_node_t* node) {
    
    switch(value->type) {
      case AST_TYPE_IDENTIFICATOR :
      case AST_TYPE_LITERAL_INT :
      case AST_TYPE_LITERAL_FLOAT :
      case AST_TYPE_LITERAL_BOOL :
      case AST_TYPE_LITERAL_CHAR :
      case AST_TYPE_LITERAL_STRING :
        break;

      //utils
      case AST_TYPE_PROGRAM_START : break;
      case AST_TYPE_FUNCTION :
        break;
      case AST_TYPE_FUNCTION_CALL :
        //printf("%s() { }", value->value);
      
      
        break;
      case AST_TYPE_BLOCK : printf("AST_TYPE_BLOCK\n"); break;
      case AST_TYPE_VECTOR : printf("AST_TYPE_VECTOR\n"); break;
      case AST_TYPE_OBJECT : printf("AST_TYPE_OBJECT\n"); break;
      case AST_TYPE_INPUT : printf("AST_TYPE_INPUT\n"); break;
      case AST_TYPE_OUTPUT : printf("AST_TYPE_OUTPUT\n"); break;

      //commmand
      case AST_TYPE_RETURN : printf("AST_TYPE_RETURN\n"); break;
      case AST_TYPE_BREAK : printf("AST_TYPE_BREAK\n"); break;
      case AST_TYPE_CONTINUE : printf("AST_TYPE_CONTINUE\n"); break;
      case AST_TYPE_IF_ELSE : printf("AST_TYPE_IF_ELSE\n"); break;
      case AST_TYPE_ATTRIBUTION : printf("AST_TYPE_ATTRIBUTION\n"); break;
      case AST_TYPE_CASE : printf("AST_TYPE_CASE\n"); break;
      case AST_TYPE_DECLR_ON_ATTR : printf("AST_TYPE_DECLR_ON_ATTR\n"); break;
      case AST_TYPE_TERNARY : printf("AST_TYPE_TERNARY\n"); break;
      case AST_TYPE_FOR : printf("AST_TYPE_FOR\n"); break;
      case AST_TYPE_FOREACH : printf("AST_TYPE_FOREACH\n"); break;
      case AST_TYPE_WHILE_DO : printf("AST_TYPE_WHILE_DO\n"); break;
      case AST_TYPE_DO_WHILE : printf("AST_TYPE_DO_WHILE\n"); break;
      case AST_TYPE_SWITCH : printf("AST_TYPE_SWITCH\n"); break;

      //logic ops
      case AST_TYPE_LS : printf("AST_TYPE_LS\n"); break;
      case AST_TYPE_LE : printf("AST_TYPE_LE\n"); break;
      case AST_TYPE_GR : printf("AST_TYPE_GR\n"); break;
      case AST_TYPE_GE : printf("AST_TYPE_GE\n"); break;
      case AST_TYPE_EQ : printf("AST_TYPE_EQ\n"); break;
      case AST_TYPE_NE : printf("AST_TYPE_NE\n"); break;
      case AST_TYPE_AND : printf("AST_TYPE_AND\n"); break;
      case AST_TYPE_OR : printf("AST_TYPE_OR\n"); break;
      case AST_TYPE_SL : printf("AST_TYPE_SL\n"); break;
      case AST_TYPE_SR : printf("AST_TYPE_SR\n"); break;
      case AST_TYPE_BW_OR : printf("AST_TYPE_BW_OR\n"); break;
      case AST_TYPE_BW_AND : printf("AST_TYPE_BW_AND\n"); break;
      case AST_TYPE_BW_XOR : printf("AST_TYPE_BW_XOR\n"); break;
      case AST_TYPE_NEGATE : printf("AST_TYPE_NEGATE\n"); break;

      // unary stuff
      case AST_TYPE_ADDRESS : printf("AST_TYPE_ADDRESS\n"); break;
      case AST_TYPE_POINTER : printf("AST_TYPE_POINTER\n"); break;
      case AST_TYPE_QUESTION_MARK : printf("AST_TYPE_QUESTION_MARK\n"); break;
      case AST_TYPE_HASHTAG : printf("AST_TYPE_HASHTAG\n"); break;

      //aritmetic ops
      case AST_TYPE_ADD : printf("AST_TYPE_ADD\n"); break;
      case AST_TYPE_SUB : printf("AST_TYPE_SUB\n"); break;
      case AST_TYPE_MUL : printf("AST_TYPE_MUL\n"); break;
      case AST_TYPE_DIV : printf("AST_TYPE_DIV\n"); break;
      case AST_TYPE_REST : printf("AST_TYPE_REST\n"); break;
      case AST_TYPE_NEGATIVE : printf("AST_TYPE_NEGATIVE\n"); break;

      // pipe and weird stuff
      case AST_TYPE_FOWARD_PIPE : printf("AST_TYPE_FOWARD_PIPE\n"); break;
      case AST_TYPE_BASH_PIPE : printf("AST_TYPE_BASH_PIPE\n"); break;
      case AST_TYPE_DOT : printf("AST_TYPE_DOT\n"); break;
      default: printf("ESQUECEU DE INSERIR BOCA ABERTA\n");
  }
}

void libera(tree_node_t *head) {
  clean_tree_DFS(head);
}