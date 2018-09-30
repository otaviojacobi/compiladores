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
  print_fancy(head);
}


void print_fancy (tree_node_t* head) {
    valor_lexico_t* value = (valor_lexico_t*)head->value;
    int header_child_amount;
    tree_node_t* parameter;

    switch (value->type) {

      case AST_TYPE_PROGRAM_START:  //OK
        head = head->first_child;
        print_fancy(head);
        break;

      case AST_TYPE_FUNCTION: //TODO
        header_child_amount = head->first_child->childAmount;
        print_fancy(head->first_child->first_child);
        printf(" "); //space between type and func_name
        fflush(stdout); 
        print_fancy(head->first_child->first_child->brother_next);
        printf("(");
        fflush(stdout); 
        
        parameter = head->first_child->first_child->brother_next->brother_next; //it means first parameter, if it exists then...
        if(parameter) {
          print_fancy(parameter);
        }

        printf(")");
        fflush(stdout);

        printf(" {\n");
        //TODO

        printf("\n}\n");

        if(head->last_child && ((valor_lexico_t*)head->last_child->value)->type == AST_TYPE_FUNCTION) {
          print_fancy(head->last_child);
        }

        break;

      case AST_TYPE_INT: printf("int"); fflush(stdout); break;       //DONE
      case AST_TYPE_FLOAT: printf("float"); fflush(stdout); break;   //DONE
      case AST_TYPE_BOOL: printf("bool"); fflush(stdout); break;     //DONE
      case AST_TYPE_CHAR: printf("char"); fflush(stdout); break;     //DONE
      case AST_TYPE_STRING: printf("string"); fflush(stdout); break; //DONE


      case AST_TYPE_FUNCTION_HEAD:  //DONE -> careful
        printf("\n\nSHOULD NOT HAPPEN\n\n");
        break;
      
      case AST_TYPE_PARAM: //DONE
        print_fancy(head->first_child);
        printf(" ");
        fflush(stdout);
        print_fancy(head->first_child->brother_next);

        if(head->first_child->brother_next->brother_next) {
          printf(", ");
          fflush(stdout);
          print_fancy(head->first_child->brother_next->brother_next);
        }
        break;

      case AST_TYPE_IDENTIFICATOR: printf("%s", value->value.stringValue); fflush(stdout); break;          //DONE
      case AST_TYPE_LITERAL_INT: printf("%d", value->value.intValue); fflush(stdout); break;              //DONE
      case AST_TYPE_LITERAL_FLOAT: printf("%f", value->value.floatValue); fflush(stdout); break;          //DONE
      case AST_TYPE_LITERAL_BOOL: printf("%s", boolToStr(value->value.boolValue)); fflush(stdout); break; //DONE
      case AST_TYPE_LITERAL_CHAR: printf("%c", value->value.charValue); fflush(stdout); break;            //DONE
      case AST_TYPE_LITERAL_STRING: printf("%s", value->value.stringValue);fflush(stdout); break;         //DONE

      //utils
      case AST_TYPE_FUNCTION_CALL: printf("AST_TYPE_FUNCTION_CALL\n");break;
      case AST_TYPE_BLOCK: printf("AST_TYPE_BLOCK\n");break;
      case AST_TYPE_VECTOR: printf("AST_TYPE_VECTOR\n");break;
      case AST_TYPE_OBJECT: printf("AST_TYPE_OBJECT\n");break;
      case AST_TYPE_INPUT: printf("AST_TYPE_INPUT\n");break;
      case AST_TYPE_OUTPUT: printf("AST_TYPE_OUTPUT\n");break;

      //commmand
      case AST_TYPE_RETURN: printf("return ");fflush(stdout);break;                      //TO FINISH (semicolon)
      case AST_TYPE_BREAK: printf("break;");fflush(stdout);break;                        //DONE
      case AST_TYPE_CONTINUE: printf("continue;");fflush(stdout);;break;                 //DONE
      case AST_TYPE_IF_ELSE: printf("AST_TYPE_IF_ELSE\n");break;
      case AST_TYPE_ATTRIBUTION: printf("AST_TYPE_ATTRIBUTION\n");break;
      case AST_TYPE_CASE: printf("AST_TYPE_CASE\n");break;
      case AST_TYPE_DECLR_ON_ATTR: printf("AST_TYPE_DECLR_ON_ATTR\n");break;
      case AST_TYPE_TERNARY: printf("AST_TYPE_TERNARY\n");break;
      case AST_TYPE_FOR: printf("AST_TYPE_FOR\n");break;
      case AST_TYPE_FOREACH: printf("AST_TYPE_FOREACH\n");break;
      case AST_TYPE_WHILE_DO: printf("AST_TYPE_WHILE_DO\n");break;
      case AST_TYPE_DO_WHILE: printf("AST_TYPE_DO_WHILE\n");break;
      case AST_TYPE_SWITCH: printf("AST_TYPE_SWITCH\n");break;

      //logic ops
      case AST_TYPE_LS: printf(" < ");fflush(stdout);break;     //DONE
      case AST_TYPE_LE: printf(" <= ");fflush(stdout);break;    //DONE
      case AST_TYPE_GR: printf(" > ");fflush(stdout);break;     //DONE
      case AST_TYPE_GE: printf(" >= ");fflush(stdout);break;    //DONE
      case AST_TYPE_EQ: printf(" == ");fflush(stdout);break;    //DONE
      case AST_TYPE_NE: printf(" != ");fflush(stdout);break;    //DONE
      case AST_TYPE_AND: printf(" && ");fflush(stdout);break;   //DONE
      case AST_TYPE_OR: printf(" || ");fflush(stdout);break;    //DONE
      case AST_TYPE_SL: printf(" << ");fflush(stdout);break;    //DONE
      case AST_TYPE_SR: printf(" >> ");fflush(stdout);break;    //DONE
      case AST_TYPE_BW_OR: printf(" | ");fflush(stdout);break;  //DONE
      case AST_TYPE_BW_AND: printf(" & ");fflush(stdout);break; //DONE
      case AST_TYPE_BW_XOR: printf(" ^ ");fflush(stdout);break; //DONE
      case AST_TYPE_NEGATE: printf(" ! ");fflush(stdout);break; //DONE

      // unary stuff
      case AST_TYPE_ADDRESS: printf(" &");fflush(stdout);break;        //DONE
      case AST_TYPE_POINTER: printf(" *");fflush(stdout);break;        //DONE
      case AST_TYPE_QUESTION_MARK: printf(" ?");fflush(stdout);break;  //DONE
      case AST_TYPE_HASHTAG: printf(" #");fflush(stdout);break;        //DONE

      //aritmetic ops
      case AST_TYPE_ADD:printf(" + ");fflush(stdout);break;     //DONE
      case AST_TYPE_SUB:printf(" - ");fflush(stdout);break;     //DONE
      case AST_TYPE_MUL:printf(" * ");fflush(stdout);break;     //DONE
      case AST_TYPE_DIV:printf(" / ");fflush(stdout);break;     //DONE
      case AST_TYPE_REST:printf(" %% ");fflush(stdout);break;     //DONE
      case AST_TYPE_NEGATIVE:printf(" !");fflush(stdout);break;     //DONE

      // pipe and weird stuff
      case AST_TYPE_FOWARD_PIPE: printf("AST_TYPE_FOWARD_PIPE\n");break;
      case AST_TYPE_BASH_PIPE: printf("AST_TYPE_BASH_PIPE\n");break;
      case AST_TYPE_DOT: printf("AST_TYPE_DOT\n");break;
      default: printf("ESQUECEU DE INSERIR BOCA ABERTA\n");
  }
  return;
}

void libera(tree_node_t *head) {
  clean_tree_DFS(head);
}