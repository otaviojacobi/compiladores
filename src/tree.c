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
  new_node->implicit_conversion = AST_TYPE_NULL;
  new_node->node_type = AST_TYPE_NULL;

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
  valor_lexico_t* vl;

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

    vl = (valor_lexico_t*) node->value;
    if(vl->type == AST_TYPE_LITERAL_STRING || vl->type == AST_TYPE_IDENTIFICATOR)
      free(vl->value.stringValue);

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
    tree_node_t* parameter;
    tree_node_t* aux_node;
    int i;
    char* stredBool;

    switch (value->type) {

      case AST_TYPE_NULL:
        printf("");
        break;

      case AST_TYPE_PROGRAM_START:  //OK
        head = head->first_child;
        print_fancy(head);
        break;

      case AST_TYPE_STATIC:
        printf("static ");
        print_fancy(head->first_child);
        aux_node = head->first_child->brother_next;
        while(aux_node){
          print_fancy(aux_node);
          aux_node = aux_node->brother_next;
        }
        break;

      case AST_TYPE_CONST:
        printf("const ");
        print_fancy(head->first_child);
        if(head && head->first_child){
          aux_node = head->first_child->brother_next;
          while(aux_node){
            print_fancy(aux_node);
            aux_node = aux_node->brother_next;
          }  
        }
        
        break;

      case AST_TYPE_GLOBAL_VAR:
        aux_node = head->first_child;
        if(((valor_lexico_t*)aux_node->brother_next->value)->type == AST_TYPE_LITERAL_INT){
          print_fancy(aux_node);
          aux_node = aux_node->brother_next;
          printf("[");
          print_fancy(aux_node);
          aux_node = aux_node->brother_next;
          printf("] ");
          print_fancy(aux_node);
        }else{
          print_fancy(aux_node);
          aux_node = aux_node->brother_next;
          printf(" ");
          print_fancy(aux_node);
        }
        printf(";\n");
        if(aux_node)
          aux_node = aux_node->brother_next;
          if(aux_node)
            print_fancy(aux_node);
        break;

      case AST_TYPE_CLASS:
        printf("class ");
        print_fancy(head->first_child);
        printf(" [\n");
        print_fancy(head->first_child->brother_next);
        printf("\n];\n");
        if(head->first_child->brother_next->brother_next)
          print_fancy(head->first_child->brother_next->brother_next);
        break;
      case AST_TYPE_CLASS_FIELD_LIST:
        aux_node = head->first_child;
        while(aux_node){
          print_fancy(aux_node);
          aux_node = aux_node->brother_next;
          if(aux_node)
            printf(" :\n");
        }
        break;
      case AST_TYPE_CLASS_FIELD:
        aux_node = head->first_child;
        while(aux_node){
          print_fancy(aux_node);
          aux_node = aux_node->brother_next;
          if(aux_node)
            printf(" ");
        }
        break;

      case AST_TYPE_PROTECTION_PRIVATE:
        printf("private ");
        break;
      case AST_TYPE_PROTECTION_PUBLIC:
        printf("public ");
        break;
      case AST_TYPE_PROTECTION_PROTECTED:
        printf("protected ");
        break;

      case AST_TYPE_FUNCTION: //TODO
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

        if(head->first_child->brother_next) {
          
          print_fancy(head->first_child->brother_next);  // this already calls the ~next~ so below doesn't seems necessary
          // aux_node = head->first_child->brother_next->first_child;
          // for(i = 1; i < head->first_child->brother_next->childAmount; i++) {
          //   aux_node = aux_node->brother_next;
          //   print_fancy(aux_node);
          // }
        }
        printf("\n");
        //printf("childAmount %d\n", head->last_child->childAmount);

        if(head->first_child->brother_next->brother_next) {
            print_fancy(head->first_child->brother_next->brother_next);
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
        break;

      case AST_TYPE_IDENTIFICATOR: printf("%s", value->value.stringValue); fflush(stdout); break;          //DONE
      case AST_TYPE_LITERAL_INT: printf("%d", value->value.intValue); fflush(stdout); break;              //DONE
      case AST_TYPE_LITERAL_FLOAT: printf("%f", value->value.floatValue); fflush(stdout); break;          //DONE
      case AST_TYPE_LITERAL_BOOL: 
        stredBool = boolToStr(value->value.boolValue);
        printf("%s", stredBool);
        free(stredBool); 
        fflush(stdout); break; //DONE
      case AST_TYPE_LITERAL_CHAR: printf("%c", value->value.charValue); fflush(stdout); break;            //DONE
      case AST_TYPE_LITERAL_STRING: printf("%s", value->value.stringValue);fflush(stdout); break;         //DONE

      //utils
      case AST_TYPE_FUNCTION_CALL:
        print_fancy(head->first_child);
        printf("(");
        if(head->first_child->brother_next){
          aux_node = head->first_child->brother_next->first_child;
          while(aux_node){
            print_fancy(aux_node);
            aux_node = aux_node->brother_next;
            if(aux_node)
              printf(", ");
          }
        }
        printf(")");
        break;

      case AST_TYPE_COMMAND_BLOCK:
        printf(" {\n");
        if(head->first_child != NULL)
          print_fancy(head->first_child);
        printf("}");
        break;

      case AST_TYPE_COMMAND:
        for(tree_node_t* itr=head->first_child; itr; itr = itr->brother_next){
          print_fancy(itr);
          printf(";\n");
        }
        break;

      case AST_TYPE_EXPRESSION_LIST:
        aux_node = head->first_child;
        while(aux_node){
          print_fancy(aux_node);
          aux_node = aux_node->brother_next;
          if(aux_node)
            printf(", ");
        }
        break;

      case AST_TYPE_VECTOR: 
        print_fancy(head->first_child);
        printf("[");
        print_fancy(head->first_child->brother_next);        
        printf("]");
        break;
      case AST_TYPE_OBJECT:
        print_fancy(head->first_child);
        printf("$");
        print_fancy(head->first_child->brother_next);
        break;
      case AST_TYPE_INPUT: 
        printf("input ");
        print_fancy(head->first_child);
        break;
      case AST_TYPE_OUTPUT: 
        printf("output ");
        print_fancy(head->first_child);
        break;

      //commmand
      case AST_TYPE_RETURN: 
        printf("return ");
        fflush(stdout);
        print_fancy(head->first_child);
        break;                                                                              //DONE
      case AST_TYPE_BREAK: printf("break");fflush(stdout);break;                        //DONE
      case AST_TYPE_CONTINUE: printf("continue");fflush(stdout);;break;                 //DONE
      case AST_TYPE_IF_ELSE:

        printf("if (");
        print_fancy(head->first_child);
        fflush(stdout);        
        printf(") then");
        fflush(stdout);
        print_fancy(head->first_child->brother_next);
        printf("");
        if(head->childAmount >= 3) {
          printf("else");
          print_fancy(head->first_child->brother_next->brother_next);
        }

        break;
      case AST_TYPE_ATTRIBUTION: 
        print_fancy(head->first_child);
        printf(" = ");
        print_fancy(head->first_child->brother_next);
        break;

      case AST_TYPE_DECLR: 
        if(head->childAmount == 3){
          print_fancy(head->first_child);
          printf(" ");
          print_fancy(head->first_child->brother_next);
          printf(" <= ");
          print_fancy(head->first_child->brother_next->brother_next);
        }else{
          print_fancy(head->first_child);
          printf(" ");
          print_fancy(head->first_child->brother_next);
        }
        break;

      case AST_TYPE_PARAM_LIST: // unite with AST_TYPE_FOR_COMMAND?
        aux_node = head->first_child;
        while(aux_node){
          print_fancy(aux_node);
          aux_node = aux_node->brother_next;
          if(aux_node)
            printf(", ");
        }
        break;

      case AST_TYPE_FOR_COMMAND: // unite with AST_TYPE_PARAM_LIST
        aux_node = head->first_child;
        while(aux_node){
          print_fancy(aux_node);
          aux_node = aux_node->brother_next;
          if(aux_node)
            printf(", ");
        }
        break;

      case AST_TYPE_CASE: 
        printf("case ");
        print_fancy(head->first_child);
        printf(":\n");
        print_fancy(head->first_child->brother_next);
        break;
      case AST_TYPE_TERNARY: 
        // for testing: uncomment the break: you will see what part is the actual ternary expression
        //printf("AST_TYPE_TERNARY");
        //break;
        print_fancy(head->first_child);
        printf(" ? ");
        print_fancy(head->first_child->brother_next);
        printf(" : ");
        print_fancy(head->first_child->brother_next->brother_next);
        break;

      case AST_TYPE_FOR: 
        printf("for (");
        print_fancy(head->first_child);
        printf(" : ");
        print_fancy(head->first_child->brother_next);
        printf(" : ");
        print_fancy(head->first_child->brother_next->brother_next);
        printf(")");
        print_fancy(head->first_child->brother_next->brother_next->brother_next);
        break;
      
      case AST_TYPE_FOREACH: 
        printf("foreach (");
        print_fancy(head->first_child);
        printf(" : ");
        print_fancy(head->first_child->brother_next);
        printf(")");
        print_fancy(head->first_child->brother_next->brother_next);
        break;

      case AST_TYPE_WHILE_DO: 
        printf("while (");
        print_fancy(head->first_child);
        printf(") do ");
        print_fancy(head->first_child->brother_next);
        break;

      case AST_TYPE_DO_WHILE: 
        printf("do ");
        print_fancy(head->first_child);
        printf("while (");
        print_fancy(head->first_child->brother_next);
        printf(")");
        break;

      case AST_TYPE_SWITCH: 
        printf("switch (");
        print_fancy(head->first_child);
        printf(") ");
        print_fancy(head->first_child->brother_next);
        break;

      //logic ops //AL
      case AST_TYPE_LS:
        print_fancy(head->first_child);
        printf(" < ");
        print_fancy(head->last_child);
        fflush(stdout);
        break;
      case AST_TYPE_LE:
        print_fancy(head->first_child);
        printf(" <= ");
        print_fancy(head->last_child);
        fflush(stdout);
        break;
      case AST_TYPE_GR:
        print_fancy(head->first_child);
        printf(" > ");
        print_fancy(head->last_child);
        fflush(stdout);
        break;
      case AST_TYPE_GE:
        print_fancy(head->first_child);
        printf(" >= ");
        print_fancy(head->last_child);
        fflush(stdout);
        break;
      case AST_TYPE_EQ:
        print_fancy(head->first_child);
        printf(" == ");
        print_fancy(head->last_child);
        fflush(stdout);
        break;
      case AST_TYPE_NE:
        print_fancy(head->first_child);
        printf(" != ");
        print_fancy(head->last_child);
        fflush(stdout);
        break;
      case AST_TYPE_AND:
        print_fancy(head->first_child);
        printf(" && ");
        print_fancy(head->last_child);
        fflush(stdout);
        break;
      case AST_TYPE_OR:
        print_fancy(head->first_child);
        printf(" || ");
        print_fancy(head->last_child);
        fflush(stdout);
        break;
      case AST_TYPE_SL:
        print_fancy(head->first_child);
        printf(" << ");
        print_fancy(head->last_child);
        fflush(stdout);
        break;
      case AST_TYPE_SR:
        print_fancy(head->first_child);
        printf(" >> ");
        print_fancy(head->last_child);
        fflush(stdout);
        break;
      case AST_TYPE_BW_OR:
        print_fancy(head->first_child);
        printf(" | ");
        print_fancy(head->last_child);
        fflush(stdout);
        break;
      case AST_TYPE_BW_AND:
        print_fancy(head->first_child);
        printf(" & ");
        print_fancy(head->last_child);
        fflush(stdout);
        break;
      case AST_TYPE_BW_XOR:
        print_fancy(head->first_child);
        printf(" ^ ");
        print_fancy(head->last_child);
        fflush(stdout);
        break;


      // unary stuff
      case AST_TYPE_ADDRESS: 
        printf(" &");
        print_fancy(head->first_child);
        fflush(stdout);
        break;
      case AST_TYPE_POINTER: 
        printf(" *");
        print_fancy(head->first_child);
        fflush(stdout);
        break;
      case AST_TYPE_QUESTION_MARK: 
        printf(" ?");
        print_fancy(head->first_child);
        fflush(stdout);
        break;
      case AST_TYPE_HASHTAG: 
        printf(" #");
        print_fancy(head->first_child);
        fflush(stdout);
        break;
      case AST_TYPE_NEGATE:
        printf(" !");
        print_fancy(head->first_child);
        fflush(stdout);
        break;
      case AST_TYPE_NEGATIVE:
        printf(" - ");
        print_fancy(head->first_child);
        fflush(stdout);
        break;

      //aritmetic ops // ALL DONE
      case AST_TYPE_ADD:
        print_fancy(head->first_child);
        printf(" + ");
        print_fancy(head->last_child);
        fflush(stdout);
        break;
      case AST_TYPE_SUB:
        print_fancy(head->first_child);
        printf(" - ");
        print_fancy(head->last_child);
        fflush(stdout);
        break;
      case AST_TYPE_MUL:
        print_fancy(head->first_child);
        printf(" * ");
        print_fancy(head->last_child);
        fflush(stdout);
        break;
      case AST_TYPE_DIV:
        print_fancy(head->first_child);
        printf(" / ");
        print_fancy(head->last_child);
        fflush(stdout);
        break;
      case AST_TYPE_REST:
        print_fancy(head->first_child);
        printf(" %% ");
        print_fancy(head->last_child);
        fflush(stdout);
        break;

      // pipe and weird stuff
      case AST_TYPE_FOWARD_PIPE:
        print_fancy(head->first_child);
        printf(" %%>%% ");
        print_fancy(head->first_child->brother_next);
        break;
      
      case AST_TYPE_BASH_PIPE: 
        print_fancy(head->first_child);
        printf(" %%|%% ");
        print_fancy(head->first_child->brother_next);
        break;

      case AST_TYPE_USED_DOT:
      case AST_TYPE_DOT: printf("."); break;
      
      default: printf("ESQUECEU DE INSERIR BOCA ABERTA\n");
  }
  return;
}

void libera(tree_node_t *head) {
  clean_tree_DFS(head);
}
