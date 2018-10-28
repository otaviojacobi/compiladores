%code requires {
  #include "valor_lexico.h"
  #include "stdio.h"
  #include "tree.h"
  #include "stack.h"
  #include "err.h"
  #include "scope_stack.h"
  #include "symbol_table.h"
}

%{
  #define ERROR_MESSAGE_MAX_LENGTH 200
  #define str(x) #x
  #define xstr(x) str(x)
  #include "tree.h"
  #include "stack.h"
  #include "err.h"
  #include "scope_stack.h"
  #include "symbol_table.h"

  extern tree_node_t *arvore;
  extern stack_node_t *tables;
  extern symbol_table_t *outer_table;
  symbol_table_t *inner_scope;
  char err_msg[ERROR_MESSAGE_MAX_LENGTH];
  token_type_t return_type;
  char *func_return_type_name;


  int yylex(void);
  void yyerror (char const *s);
  int get_line_number(void);
  tree_node_t* MakeNode(token_type_t type, valor_lexico_t* valor_lexico);
  void InsertChild(tree_node_t *father, tree_node_t *children);
  token_type_t CheckExpression(tree_node_t *node);
  int get_type_size(token_type_t type, char* name);
  void create_global_value( valor_lexico_t *first, tree_node_t *second, int is_vector );
  void find_in_object(valor_lexico_t *first, valor_lexico_t *second, int is_vector);
  int is_compact(token_type_t t1, token_type_t t2);
  const char* type_to_str(token_type_t tkn);
  token_type_t get_next_dot_proposed_type(tree_node_t* node);
%}

%error-verbose

%token TK_PR_INT
%token TK_PR_FLOAT
%token TK_PR_BOOL
%token TK_PR_CHAR
%token TK_PR_STRING
%token TK_PR_IF
%token TK_PR_THEN
%token TK_PR_ELSE
%token TK_PR_WHILE
%token TK_PR_DO
%token TK_PR_INPUT
%token TK_PR_OUTPUT
%token TK_PR_RETURN
%token TK_PR_CONST
%token TK_PR_STATIC
%token TK_PR_FOREACH
%token TK_PR_FOR
%token TK_PR_SWITCH
%token TK_PR_CASE
%token TK_PR_BREAK
%token TK_PR_CONTINUE
%token TK_PR_CLASS
%token TK_PR_PRIVATE
%token TK_PR_PUBLIC
%token TK_PR_PROTECTED
%token TK_OC_LE
%token TK_OC_GE
%token TK_OC_EQ
%token TK_OC_NE
%token TK_OC_AND
%token TK_OC_OR
%token TK_OC_SL
%token TK_OC_SR
%token TK_OC_FORWARD_PIPE
%token TK_OC_BASH_PIPE
%token TK_LIT_INT
%token TK_LIT_FLOAT
%token TK_LIT_FALSE
%token TK_LIT_TRUE
%token TK_LIT_CHAR
%token TK_LIT_STRING
%token TK_IDENTIFICADOR
%token TOKEN_ERRO


%type <valor_lexico> TK_LIT_INT
%type <valor_lexico> TK_LIT_FLOAT
%type <valor_lexico> TK_LIT_FALSE
%type <valor_lexico> TK_LIT_TRUE
%type <valor_lexico> TK_LIT_CHAR
%type <valor_lexico> TK_LIT_STRING
%type <valor_lexico> TK_IDENTIFICADOR


%type <node> func_head
%type <node> programa_rec
%type <node> func
%type <node> command_block
%type <node> command_seq
%type <node> simple_command
%type <node> simple_command_for
%type <node> case;
%type <node> local_var_decl
%type <node> local_var_static_consumed
%type <node> local_var_const_consumed

%type <node> std_type_node
%type <node> std_type
%type <node> param
%type <node> parameters
%type <node> param_list
%type <node> attribution
%type <node> input
%type <node> shift_cmd
%type <node> return
%type <node> break
%type <node> continue
%type <node> conditional_command
%type <node> foreach
%type <node> while_do
%type <node> do_while
%type <node> output
%type <node> switch
%type <node> func_call
%type <node> for
%type <node> expression
%type <node> args
%type <node> identificador_accessor
%type <node> tk_lit
%type <node> pipe_command
%type <node> pipe_rec
%type <node> expression_list
%type <node> for_command_list
%type <node> new_type_decl
%type <node> field_list
%type <node> field
%type <node> protection
%type <node> global_var_decl
%type <node> gv_type


%union {
  valor_lexico_t* valor_lexico;
  tree_node_t* node;
}
//The first precedence/associativity declaration in the file declares the operators whose precedence is lowest
//the next such declaration declares the operators whose precedence is a little higher, and so on.
// Created this following standard C precendence

%left '!' ':'
%left TK_OC_OR
%left TK_OC_AND
%left '|'
%left '^'
%right '&'
%left TK_OC_EQ TK_OC_NE 
%left '<' TK_OC_LE '>' TK_OC_GE
%left '+' '-'
%left '/' '%'
%right '*'

//TODO: Should this be max prio ?

%right '#' '?'
//TODO: Is case a command ? wtf

%%

programa: programa_rec {arvore = MakeNode(AST_TYPE_PROGRAM_START, NULL); InsertChild(arvore, $1);}
;

programa_rec:  new_type_decl programa_rec  { InsertChild($1, $2); $$ = $1; }
             | global_var_decl programa_rec  {  InsertChild($1, $2); $$ = $1; }
             | func programa_rec { InsertChild($1, $2); $$ = $1; }
             | %empty { $$ = MakeNode(AST_TYPE_NULL, NULL); }
;

std_type: std_type_node { $$ = $1; };
//TK_PR_INT | TK_PR_FLOAT | TK_PR_BOOL | TK_PR_CHAR | TK_PR_STRING;

protection: TK_PR_PRIVATE { 
  $$ = MakeNode(AST_TYPE_PROTECTION_PRIVATE, NULL);
}
| TK_PR_PUBLIC { 
  $$ = MakeNode(AST_TYPE_PROTECTION_PUBLIC, NULL);
}
| TK_PR_PROTECTED { 
  $$ = MakeNode(AST_TYPE_PROTECTION_PROTECTED, NULL);
};

std_type_node: 
TK_PR_INT {
  $$ = MakeNode(AST_TYPE_INT, NULL);
}
| TK_PR_FLOAT {
  $$ = MakeNode(AST_TYPE_FLOAT, NULL);
}
| TK_PR_BOOL {
  $$ = MakeNode(AST_TYPE_BOOL, NULL);
}
| TK_PR_CHAR {
  $$ = MakeNode(AST_TYPE_CHAR, NULL);
}
| TK_PR_STRING {
  $$ = MakeNode(AST_TYPE_STRING, NULL);
};


tk_lit:
TK_LIT_INT       { $$ = MakeNode(AST_TYPE_LITERAL_INT, $1); }
| TK_LIT_FLOAT   { $$ = MakeNode(AST_TYPE_LITERAL_FLOAT, $1); }
| TK_LIT_FALSE   { $$ = MakeNode(AST_TYPE_LITERAL_BOOL, $1); }
| TK_LIT_TRUE    { $$ = MakeNode(AST_TYPE_LITERAL_BOOL, $1); }
| TK_LIT_CHAR    { $$ = MakeNode(AST_TYPE_LITERAL_CHAR, $1); }
| TK_LIT_STRING  { $$ = MakeNode(AST_TYPE_LITERAL_STRING, $1); }
;

identificador_accessor:
TK_IDENTIFICADOR
{
  $$ = MakeNode(AST_TYPE_IDENTIFICATOR, $1);

  char* identifier = $1->value.stringValue;
  symbol_table_t *st = find_item(tables, identifier);

  if( st == NULL) {
    sprintf(err_msg, "line %d: %s '%s' %s\n", get_line_number(),"Identificator", identifier, "has not been declared");
    quit(ERR_UNDECLARED, err_msg);
  }

  if(st->item->is_vector) {
    sprintf(err_msg, "line %d: %s '%s' %s\n", get_line_number(),"Vector", identifier, "should be accessed as vector.");
    quit(ERR_VECTOR, err_msg);
  }

  if(st->item->nature == NATUREZA_FUNCAO) {
    sprintf(err_msg, "line %d: %s '%s' %s\n", get_line_number(),"Function ", identifier, "should be accessed as function.");
    quit(ERR_FUNCTION, err_msg);
  }
}
| TK_IDENTIFICADOR '$' TK_IDENTIFICADOR
{
  $$ = MakeNode(AST_TYPE_OBJECT, NULL);
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $1));
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $3));

  find_in_object($1, $3, 0);

}
| TK_IDENTIFICADOR '[' expression ']'
{
  $$ = MakeNode(AST_TYPE_VECTOR, NULL);
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $1));
  InsertChild($$, $3);
  token_type_t t = CheckExpression($3);

  if(t == AST_TYPE_CHAR) {
    sprintf(err_msg, "line %d: %s\n", get_line_number(),"Invalid cast for char.");
    quit(ERR_CHAR_TO_X, err_msg);
  }

  if(t == AST_TYPE_STRING) {
    sprintf(err_msg, "line %d: %s\n", get_line_number(),"Invalid cast for string.");
    quit(ERR_STRING_TO_X, err_msg);
  }

  if(t != AST_TYPE_BOOL && t != AST_TYPE_INT && t != AST_TYPE_FLOAT){
    sprintf(err_msg, "line %d: %s\n", get_line_number(),"You're trying to access a vector with some invalid type");
    quit(ERR_VECTOR, err_msg);
  }


  char* identifier = $1->value.stringValue;

  symbol_table_t *st = find_item(tables, identifier);
  if( st == NULL) {
    sprintf(err_msg, "line %d: %s '%s' %s\n", get_line_number(),"Identificator", identifier, "has not been declared");
    quit(ERR_UNDECLARED, err_msg);
  }

  if(st->item->is_vector <= 0) {
    sprintf(err_msg, "line %d: %s %s\n", get_line_number(), identifier, "is not a vector");
    quit(ERR_VARIABLE, err_msg);
  }
}
| TK_IDENTIFICADOR '[' expression ']' '$' TK_IDENTIFICADOR
{
  tree_node_t* vector = MakeNode(AST_TYPE_VECTOR, NULL);
  InsertChild(vector, MakeNode(AST_TYPE_IDENTIFICATOR, $1));
  InsertChild(vector, $3);

  $$ = MakeNode(AST_TYPE_OBJECT, NULL);
  InsertChild($$, vector);
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $6));

  find_in_object($1, $6, 1);

}
;

new_type_decl: TK_PR_CLASS TK_IDENTIFICADOR '[' field_list ']' ';' {
  $$ = MakeNode(AST_TYPE_CLASS, NULL);
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $2));
  InsertChild($$, $4);

  char* identifier = $2->value.stringValue, *aux_str;

  if(find_item(tables, identifier)) {
    sprintf(err_msg, "line %d: %s '%s' %s\n", get_line_number(),"Variable", identifier, "has already been declared");
    quit(ERR_DECLARED, err_msg);
  }

  symbol_table_item_t* item = (symbol_table_item_t*)malloc(sizeof(symbol_table_item_t));

  arg_list_t *params = NULL, *p_create = NULL, *p_last = NULL;
  tree_node_t *aux = $4->first_child;
  token_type_t aux_type;

  int counter = 0;
  while(aux != NULL) {
    p_create = (arg_list_t*)malloc(sizeof(arg_list_t));

    aux_type = ((valor_lexico_t*)aux->first_child->value)->type; //TODO:FIXME FOR PROTECTION

    if(aux_type == AST_TYPE_PROTECTION_PRIVATE || aux_type == AST_TYPE_PROTECTION_PUBLIC || aux_type == AST_TYPE_PROTECTION_PROTECTED) {
      p_create->type = ((valor_lexico_t*)aux->first_child->brother_next->value)->type;
      p_create->field_name = strdup(((valor_lexico_t*)aux->first_child->brother_next->brother_next->value)->value.stringValue);
      p_create->next = NULL;
      p_create->protec_level = aux_type;
    } else {
      p_create->type = aux_type;
      p_create->field_name = strdup(((valor_lexico_t*)aux->first_child->brother_next->value)->value.stringValue);
      p_create->next = NULL;
    }

    if(counter == 0) {
      params = p_create;
    } else {
      p_last->next = p_create;
    }
    p_last = p_create;

    aux = aux->brother_next;
    counter++;
  }

  tree_node_t *child = $4->first_child;
  int __acc_size_struct=0;
  for(; child != NULL; child = child->brother_next){
    valor_lexico_t* __field_data = (valor_lexico_t*) child->first_child->value;
    __acc_size_struct+=get_type_size(__field_data->type, NULL);
  }
  create_table_item(item, get_line_number(), NATUREZA_CLASS, AST_TYPE_CLASS,__acc_size_struct, params,$2->value, 0, 0, 0);
  if(add_item(tables, identifier, item) == -1){
    sprintf(err_msg, "line %d: %s '%s' %s\n", get_line_number(),"Variable", identifier, "has already been declared");
    quit(ERR_DECLARED, err_msg);
  }

};
field_list: field_list ':' field 
{
  $$ = $1;
  InsertChild($$, $3);
}
| field
{
  $$ = MakeNode(AST_TYPE_CLASS_FIELD_LIST, NULL);
  InsertChild($$, $1);
}
;
field: protection std_type TK_IDENTIFICADOR 
{ 
  $$ = MakeNode(AST_TYPE_CLASS_FIELD, NULL);
  InsertChild($$, $1);                        
  InsertChild($$, $2);                        
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $3));
}
| std_type TK_IDENTIFICADOR 
{ 
  $$ = MakeNode(AST_TYPE_CLASS_FIELD, NULL);
  InsertChild($$, $1);                        
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $2));
};

global_var_decl: TK_IDENTIFICADOR gv_type ';' {
  $$ = MakeNode(AST_TYPE_GLOBAL_VAR, NULL);
  InsertChild($$, MakeNode(TK_IDENTIFICADOR, $1));
  InsertChild($$, $2);

  tree_node_t* n2 = $2;
  create_global_value($1, $2, 0);

}
| TK_IDENTIFICADOR '[' TK_LIT_INT ']' gv_type';' {
  $$ = MakeNode(AST_TYPE_GLOBAL_VAR, NULL);
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $1));
  InsertChild($$, MakeNode(AST_TYPE_LITERAL_INT, $3));
  InsertChild($$, $5);

  create_global_value($1, $5, $3->value.intValue);

};

gv_type: TK_PR_STATIC std_type { 
  $$ = MakeNode(AST_TYPE_STATIC, NULL); 
  InsertChild($$, $2); 
}
| std_type { $$ = $1; }
| TK_PR_STATIC TK_IDENTIFICADOR { 
  $$ = MakeNode(AST_TYPE_STATIC, NULL);
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $2)); }
| TK_IDENTIFICADOR { 
  $$ = MakeNode(AST_TYPE_IDENTIFICATOR, $1);
}
;

func: func_head command_block { 
  $$ = MakeNode(AST_TYPE_FUNCTION, NULL); 
  InsertChild($$, $1); 
  InsertChild($$, $2); 
  token_type_t type = ((valor_lexico_t*)$1->first_child->value)->type;
  
  if(return_type == AST_TYPE_CLASS && type == AST_TYPE_IDENTIFICATOR){
    if(strcmp(((valor_lexico_t*) $1->first_child->value)->value.stringValue, func_return_type_name) != 0){
      sprintf(err_msg, "line %d: %s %s, %s %s\n", get_line_number(),"Returning type", func_return_type_name,"but function is of type", ((valor_lexico_t*) $1->first_child->value)->value.stringValue);
      quit(ERR_WRONG_PAR_RETURN, err_msg);
    }else
      type = return_type;
  }

  //TODO:HERE 
  if(!is_compact(type, return_type) && type != AST_TYPE_NULL && return_type != AST_TYPE_NULL){
    sprintf(err_msg, "line %d: %s %s, %s %s\n", get_line_number(),"Returning type", type_to_str(return_type),"but function is of type", type_to_str(type));
    quit(ERR_WRONG_PAR_RETURN, err_msg);
  }
  pop(&tables);
}
| TK_PR_STATIC func_head command_block {
  $$ = MakeNode(AST_TYPE_STATIC, NULL);

  tree_node_t* func = MakeNode(AST_TYPE_FUNCTION, NULL); 
  InsertChild(func, $2); 
  InsertChild(func, $3);
  InsertChild($$, func);
  pop(&tables);
  char *identifier = ((valor_lexico_t*)$2->first_child->brother_next->value)->value.stringValue;

  symbol_table_item_t *item = (symbol_table_item_t*)malloc(sizeof(symbol_table_item_t));
  symbol_table_t *aux = find_item(tables, identifier);

  memcpy(item, aux->item, sizeof(symbol_table_item_t));
  item->is_static = 1;

  if(update_item(tables, identifier, item) == -1)
    quit(-1, "Something went terrebly wrong in local_var_decl 2...");
};

func_head:  std_type_node TK_IDENTIFICADOR param_list
{
  $$ = MakeNode(AST_TYPE_FUNCTION_HEAD, NULL);
  InsertChild($$, $1);
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $2));
  InsertChild($$, $3);

  char *identifier =  $2->value.stringValue;

  symbol_table_item_t *item = (symbol_table_item_t*)malloc(sizeof(symbol_table_item_t));
  symbol_table_item_t *aux_item = NULL;
  symbol_table_t *st = NULL;


  token_type_t type = ((valor_lexico_t*)($1->value))->type;
  token_value_t value = $2->value;

  new_scope(&tables, &inner_scope);

  arg_list_t *params = NULL, *p_create = NULL, *p_last = NULL;
  tree_node_t *aux = $3;
  token_type_t aux_type;
  token_value_t aux_value;

  int counter = 0;
  int is_const;
  char *param_name;

  if(aux != NULL) {
    aux = aux->first_child;
    while(aux != NULL) {

      p_create = (arg_list_t*)malloc(sizeof(arg_list_t));
      p_create->next=NULL;
      aux_item = (symbol_table_item_t*)malloc(sizeof(symbol_table_item_t));
      
      if (((valor_lexico_t*)aux->value)->type == AST_TYPE_CONST) {
        is_const = 1;

        if(((valor_lexico_t*)aux->first_child->first_child->value)->type == AST_TYPE_IDENTIFICATOR) {
          st = find_item(tables, ((valor_lexico_t*)aux->first_child->first_child->value)->value.stringValue);
          if(st == NULL) {
            sprintf(err_msg, "line %d: %s '%s' %s\n", get_line_number(),"Parameter type", ((valor_lexico_t*)aux->first_child->first_child->value)->value.stringValue, "is not declared");
            quit(ERR_UNDECLARED, err_msg);
          }
          p_create->type = AST_TYPE_CLASS;
          p_create->field_name = strdup(st->key);
          aux_value = st->item->value;
        } else {
          p_create->type = ((valor_lexico_t*)aux->first_child->first_child->value)->type;
          aux_value = ((valor_lexico_t*)aux->first_child->first_child->brother_next->value)->value;
        }
        param_name=((valor_lexico_t*)aux->first_child->first_child->brother_next->value)->value.stringValue;
      } else {
        is_const = 0;

        if(((valor_lexico_t*)aux->first_child->value)->type == AST_TYPE_IDENTIFICATOR) {
          st = find_item(tables, ((valor_lexico_t*)aux->first_child->value)->value.stringValue);
          if(st == NULL) {
            sprintf(err_msg, "line %d: %s '%s' %s\n", get_line_number(),"Parameter", ((valor_lexico_t*)aux->first_child->value)->value.stringValue, "is not declared");
            quit(ERR_UNDECLARED, err_msg);
          }
          p_create->field_name = strdup(st->key);
          p_create->type = AST_TYPE_CLASS;
          aux_value = st->item->value;
        } else {
          p_create->type = ((valor_lexico_t*)aux->first_child->value)->type;
          aux_value = ((valor_lexico_t*)aux->first_child->brother_next->value)->value;
        }
        param_name=((valor_lexico_t*)aux->first_child->brother_next->value)->value.stringValue;
      }
      aux_type = p_create->type;

      create_table_item(aux_item, get_line_number(), NATUREZA_IDENTIFICADOR, aux_type, get_type_size(aux_type, aux_value.stringValue),NULL, aux_value, is_const, 0, 0);

      if(add_item(tables, param_name, aux_item) == -1){
        sprintf(err_msg, "line %d: %s '%s' %s\n", get_line_number(),"Parameter", param_name, "has already been declared");
        quit(ERR_DECLARED, err_msg);
      }

      if(counter == 0) {
        params = p_create;
      } else {
        p_last->next = p_create;
      }
      
      p_last = p_create;

      aux = aux->brother_next;
      counter++;
    }
  }

  create_table_item(item, get_line_number(), NATUREZA_FUNCAO, type, get_type_size(type, value.stringValue),params, value, 0, 0, 0);
  //TODO: if comipling fails the problem might be here -> couldn't test
  if(_add_item(&outer_table, value.stringValue, item) == -1){
    sprintf(err_msg, "line %d: %s '%s' %s\n", get_line_number(),"Variable", value.stringValue, "has already been declared");
    quit(ERR_DECLARED, err_msg);
  }

}
| TK_IDENTIFICADOR TK_IDENTIFICADOR param_list
{
  $$ = MakeNode(AST_TYPE_FUNCTION_HEAD, NULL);
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $1));
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $2));
  InsertChild($$, $3);
  
    char *identifier =  $2->value.stringValue;

  symbol_table_item_t *item = (symbol_table_item_t*)malloc(sizeof(symbol_table_item_t));
  symbol_table_item_t *aux_item = NULL;
  symbol_table_t *st = NULL;


  token_type_t type = AST_TYPE_IDENTIFICATOR;
  token_value_t value = $2->value;

  new_scope(&tables, &inner_scope);

  arg_list_t *params = NULL, *p_create = NULL, *p_last = NULL;
  tree_node_t *aux = $3;
  token_type_t aux_type;
  token_value_t aux_value;

  int counter = 0;
  int is_const;
  char *param_name;

  if(aux != NULL) {
    aux = aux->first_child;
    while(aux != NULL) {

      p_create = (arg_list_t*)malloc(sizeof(arg_list_t));
      aux_item = (symbol_table_item_t*)malloc(sizeof(symbol_table_item_t));
      
      if (((valor_lexico_t*)aux->value)->type == AST_TYPE_CONST) {
        is_const = 1;

        if(((valor_lexico_t*)aux->first_child->first_child->value)->type == AST_TYPE_IDENTIFICATOR) {
          st = find_item(tables, ((valor_lexico_t*)aux->first_child->first_child->value)->value.stringValue);
          if(st == NULL) {
            sprintf(err_msg, "line %d: %s '%s' %s\n", get_line_number(),"Parameter type", ((valor_lexico_t*)aux->first_child->first_child->value)->value.stringValue, "is not declared");
            quit(ERR_UNDECLARED, err_msg);
          }
          p_create->type = AST_TYPE_CLASS;
          p_create->field_name = strdup(st->key);
          aux_value = st->item->value;
        } else {
          p_create->type = ((valor_lexico_t*)aux->first_child->first_child->value)->type;
          aux_value = ((valor_lexico_t*)aux->first_child->first_child->brother_next->value)->value;
        }
        param_name=((valor_lexico_t*)aux->first_child->first_child->brother_next->value)->value.stringValue;
      } else {
        is_const = 0;

        if(((valor_lexico_t*)aux->first_child->value)->type == AST_TYPE_IDENTIFICATOR) {
          st = find_item(tables, ((valor_lexico_t*)aux->first_child->value)->value.stringValue);
          if(st == NULL) {
            sprintf(err_msg, "line %d: %s '%s' %s\n", get_line_number(),"Parameter type", ((valor_lexico_t*)aux->first_child->value)->value.stringValue, "is not declared");
            quit(ERR_UNDECLARED, err_msg);
          }
          p_create->field_name = strdup(st->key);
          p_create->type = AST_TYPE_CLASS;
          aux_value = st->item->value;
        } else {
          p_create->type = ((valor_lexico_t*)aux->first_child->value)->type;
          aux_value = ((valor_lexico_t*)aux->first_child->brother_next->value)->value;
        }
        param_name=((valor_lexico_t*)aux->first_child->brother_next->value)->value.stringValue;
      }
      aux_type = p_create->type;

      create_table_item(aux_item, get_line_number(), NATUREZA_IDENTIFICADOR, aux_type, get_type_size(aux_type, aux_value.stringValue),NULL, aux_value, is_const, 0, 0);

      if(add_item(tables, param_name, aux_item) == -1){
        sprintf(err_msg, "line %d: %s '%s' %s\n", get_line_number(),"Parameter", param_name, "has already been declared");
        quit(ERR_DECLARED, err_msg);

      }
      
      if(counter == 0) {
        params = p_create;
      } else {
        p_last->next = p_create;
      }
      p_last = p_create;

      aux = aux->brother_next;
      counter++;
    }
  }

  create_table_item(item, get_line_number(), NATUREZA_FUNCAO, type, 0,params, value, 0, 0, 0);
  if(add_item(tables->next, value.stringValue, item) == -1){
    sprintf(err_msg, "line %d: %s '%s' %s\n", get_line_number(),"Function", value.stringValue, "has already been declared");
    quit(ERR_DECLARED, err_msg);

  }

};

param_list: '(' parameters ')' { $$ = $2;
  // before chanding the way parameters are added in a chain to access third parameter ID:
  //$2->first_child->brother_next->brother_next->brother_next->first_child->brother_next;
  //printf("value=%s\n", ((valor_lexico_t*)head->value)->value.stringValue);
  // now it is mounted recursively -> next parameter is always the third child of the previous
} | '(' ')' { $$ = NULL; };

parameters: 
parameters ',' param {
  if($1 != NULL) {
    InsertChild($1, $3);
    $$ = $1;
  } else {
    $$ = $3;
  }
}
| param {
  $$ = MakeNode(AST_TYPE_PARAM_LIST, NULL);
  InsertChild($$, $1);
};

param:  
std_type_node TK_IDENTIFICADOR {
  $$ = MakeNode(AST_TYPE_PARAM, NULL);
  InsertChild($$, $1);
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $2));
}

| TK_PR_CONST std_type_node TK_IDENTIFICADOR {
  tree_node_t* aux = MakeNode(AST_TYPE_PARAM, NULL);
  InsertChild(aux, $2);
  InsertChild(aux, MakeNode(AST_TYPE_IDENTIFICATOR, $3));
  $$ = MakeNode(AST_TYPE_CONST, NULL);
  InsertChild($$, aux);
}

| TK_IDENTIFICADOR TK_IDENTIFICADOR {
  $$ = MakeNode(AST_TYPE_PARAM, NULL);
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $1));
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $2));
}

| TK_PR_CONST TK_IDENTIFICADOR TK_IDENTIFICADOR {
  tree_node_t* aux = MakeNode(AST_TYPE_PARAM, NULL);
  InsertChild(aux, MakeNode(AST_TYPE_IDENTIFICATOR, $2));
  InsertChild(aux, MakeNode(AST_TYPE_IDENTIFICATOR, $3));
  $$ = MakeNode(AST_TYPE_CONST, NULL);
  InsertChild($$, aux);
};

command_block: '{' command_seq '}' { 
  $$ = MakeNode(AST_TYPE_COMMAND_BLOCK, NULL); 
  InsertChild($$, $2); 
} | '{' '}' { 
  $$ = MakeNode(AST_TYPE_COMMAND_BLOCK, NULL); 
};

command_seq: command_seq simple_command
{
  if($1 != NULL) {
    InsertChild($1, $2); 
    $$ = $1;
  } else {
    $$ = $2;
  }
}
| simple_command
{
  $$ = MakeNode(AST_TYPE_COMMAND, NULL);
  InsertChild($$, $1);
};

for_command_list: 
for_command_list ',' simple_command_for 
{
  if($1 != NULL) {
    InsertChild($1, $3);
    $$ = $1;
  } else {
    $$ = $3;
  }
}
| simple_command_for
{
  $$ = MakeNode(AST_TYPE_FOR_COMMAND, NULL); 
  InsertChild($$, $1);
}
;

simple_command:   command_block ';'       { $$ = $1; }
                | local_var_decl ';'      { $$ = $1; }
                | attribution ';'         { $$ = $1; }
                | input ';'               { $$ = $1; }
                | shift_cmd ';'           { $$ = $1; }
                | return ';'              { $$ = $1; }
                | break ';'               { $$ = $1; }
                | continue ';'            { $$ = $1; }
                | conditional_command ';' { $$ = $1; }
                | foreach ';'             { $$ = $1; }
                | while_do ';'            { $$ = $1; }
                | do_while ';'            { $$ = $1; }
                | pipe_command ';'        { $$ = $1; }
                | case ';'                { $$ = $1; }
                | output ';'              { $$ = $1; }
                | switch ';'              { $$ = $1; }
                | func_call ';'           { $$ = $1; }
                | for ';'                 { $$ = $1; }
;

simple_command_for:  command_block       { $$ = $1; }
                   | local_var_decl      { $$ = $1; }
                   | attribution         { $$ = $1; }
                   | input               { $$ = $1; }
                   | shift_cmd           { $$ = $1; }
                   | return              { $$ = $1; }
                   | break               { $$ = $1; }
                   | continue            { $$ = $1; }
                   | conditional_command { $$ = $1; }
                   | foreach             { $$ = $1; }
                   | while_do            { $$ = $1; }
                   | do_while            { $$ = $1; }
                   | pipe_command        { $$ = $1; }
                   | case                { $$ = $1; }
;

break: TK_PR_BREAK        { $$ = MakeNode(AST_TYPE_BREAK, NULL); };
continue: TK_PR_CONTINUE  { $$ = MakeNode(AST_TYPE_CONTINUE, NULL); };

case: TK_PR_CASE TK_LIT_INT ':' command_block 
{
  $$ = MakeNode(AST_TYPE_CASE, NULL);
  InsertChild($$, MakeNode(AST_TYPE_LITERAL_INT, $2));
  InsertChild($$, $4);
};

local_var_decl: TK_PR_STATIC local_var_static_consumed { 
  $$ = MakeNode(AST_TYPE_STATIC, NULL); 
  InsertChild($$, $2);

  char* identifier;

  if ( ((valor_lexico_t*)$2->value)->type == AST_TYPE_CONST ) {
    identifier = ((valor_lexico_t*)($2->first_child->first_child->brother_next->value))->value.stringValue;
  } else if ( ((valor_lexico_t*)$2->value)->type == AST_TYPE_DECLR ) {
    identifier = ((valor_lexico_t*)($2->first_child->brother_next->value))->value.stringValue;
  } else {
    quit(-1, "Something went terrebly wrong in local_var_decl...");
  }

  symbol_table_item_t *item = (symbol_table_item_t*)malloc(sizeof(symbol_table_item_t));
  symbol_table_t *aux = find_item(tables, identifier);
  memcpy(item, aux->item, sizeof(symbol_table_item_t));
  item->is_static = 1;

  if(update_item(tables, identifier, item) == -1)
    quit(-1, "Something went terrebly wrong in local_var_decl 2...");

}
| local_var_static_consumed { $$ = $1; };
local_var_static_consumed: TK_PR_CONST local_var_const_consumed {

  $$ = MakeNode(AST_TYPE_CONST, NULL);
  InsertChild($$, $2);

  symbol_table_item_t *item = (symbol_table_item_t*)malloc(sizeof(symbol_table_item_t));
  char* identifier = ((valor_lexico_t*)($2->first_child->brother_next->value))->value.stringValue;

  symbol_table_t *aux = find_item(tables, identifier);

  memcpy(item, aux->item, sizeof(symbol_table_item_t));
  item->is_const = 1;

  if(update_item(tables, identifier, item) == -1)
    quit(-1, "Something went terrebly wrong in local_var_static_consumed...");

}

| local_var_const_consumed { $$ = $1; };

local_var_const_consumed:  
std_type TK_IDENTIFICADOR { 
  $$ = MakeNode(AST_TYPE_DECLR, NULL); 
  InsertChild($$, $1);
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $2));

  symbol_table_item_t *item = (symbol_table_item_t*)malloc(sizeof(symbol_table_item_t));
  
  token_type_t type = ((valor_lexico_t*)$1->value)->type;
  token_value_t value = ((valor_lexico_t*)$2)->value;

  create_table_item(item, get_line_number(), NATUREZA_IDENTIFICADOR, type, get_type_size(type, value.stringValue),NULL, value, 0, 0, 0);
  if(add_item(tables, value.stringValue, item) == -1){
    sprintf(err_msg, "line %d: %s '%s' %s\n", get_line_number(),"Identificator", value.stringValue, "has already been declared");
    quit(ERR_DECLARED, err_msg);
  }

}
| TK_IDENTIFICADOR TK_IDENTIFICADOR { 
  $$ = MakeNode(AST_TYPE_DECLR, NULL); 
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $1));
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $2));

  symbol_table_item_t *item = (symbol_table_item_t*)malloc(sizeof(symbol_table_item_t));

  token_value_t value = $1->value;
  char *identifier = ((valor_lexico_t*)$2)->value.stringValue;

  if(find_item(tables, value.stringValue) == NULL) {
    sprintf(err_msg, "line %d: %s '%s' %s\n", get_line_number(),"Identifier", value.stringValue, "is not declared");
    quit(ERR_UNDECLARED, err_msg);
  }


  create_table_item(item, get_line_number(), NATUREZA_IDENTIFICADOR, AST_TYPE_CLASS,get_type_size(AST_TYPE_IDENTIFICATOR, value.stringValue),NULL, value, 0, 0, 0); 
  if(add_item(tables, identifier, item) == -1){
    sprintf(err_msg, "line %d: %s '%s' %s\n", get_line_number(),"Variable", identifier, "has already been declared");
    quit(ERR_DECLARED, err_msg);

  }


}
| std_type TK_IDENTIFICADOR TK_OC_LE TK_IDENTIFICADOR
{
  $$ = MakeNode(AST_TYPE_DECLR, NULL);
  InsertChild($$, $1);
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $2));
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $4));

  char *identifier = ((valor_lexico_t*)$2)->value.stringValue;
  symbol_table_item_t *item = (symbol_table_item_t*)malloc(sizeof(symbol_table_item_t));

  symbol_table_t *st = find_item(tables, ((valor_lexico_t*)$4)->value.stringValue);
  if( st == NULL ) {
    sprintf(err_msg, "line %d: %s '%s' %s\n", get_line_number(),"Variable", ((valor_lexico_t*)$4)->value.stringValue, "is not declared");
    quit(ERR_UNDECLARED, err_msg);
  }

  if(st->item->type == AST_TYPE_CLASS) {
    sprintf(err_msg, "line %d: %s\n", get_line_number(),"Wrong type on assertion");
    quit(ERR_USER_TO_X, err_msg);
  }

  token_type_t type = ((valor_lexico_t*)$1->value)->type;
  token_type_t incoming_type = st->item->type;

  if( (type == AST_TYPE_STRING && incoming_type != AST_TYPE_STRING) ||
      (type != AST_TYPE_STRING && incoming_type == AST_TYPE_STRING) ){
    sprintf(err_msg, "line %d: %s\n", get_line_number(),"Strings can't be implicitly converted.!");quit(ERR_STRING_TO_X, err_msg);
  }

  if ( (type == AST_TYPE_CHAR && incoming_type != AST_TYPE_CHAR) ||
       (type != AST_TYPE_CHAR && incoming_type == AST_TYPE_CHAR) ){
    sprintf(err_msg, "line %d: %s\n", get_line_number(),"Char can't be implicitly converted.");
    quit(ERR_CHAR_TO_X, err_msg);
  }

  create_table_item(item, get_line_number(), NATUREZA_IDENTIFICADOR, type, get_type_size(type, $2->value.stringValue), NULL, $2->value, 0, 0, 0);
  if(add_item(tables, identifier, item) == -1){
    sprintf(err_msg, "line %d: %s '%s' %s\n", get_line_number(),"Variable", identifier, "has already been declared");
    quit(ERR_DECLARED, err_msg);

  }

}
| std_type TK_IDENTIFICADOR TK_OC_LE tk_lit
{
  $$ = MakeNode(AST_TYPE_DECLR, NULL);
  InsertChild($$, $1);
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $2));
  InsertChild($$, $4);

  symbol_table_item_t *item = (symbol_table_item_t*)malloc(sizeof(symbol_table_item_t));
  token_value_t value = ((valor_lexico_t*)$2)->value;  
  token_type_t type = ((valor_lexico_t*)$1->value)->type;
  
  token_type_t incoming_type = ((valor_lexico_t*)$4->value)->type;

  if((type == AST_TYPE_STRING && incoming_type != AST_TYPE_LITERAL_STRING) ||
     (type != AST_TYPE_STRING && incoming_type == AST_TYPE_LITERAL_STRING) ){
    sprintf(err_msg, "line %d: %s\n", get_line_number(),"Strings can't be implicitly converted..");
    quit(ERR_STRING_TO_X, err_msg);
  }

  if((type == AST_TYPE_CHAR && incoming_type != AST_TYPE_LITERAL_CHAR) ||
     (type != AST_TYPE_CHAR && incoming_type == AST_TYPE_LITERAL_CHAR) ){
    sprintf(err_msg, "line %d: %s\n", get_line_number(),"Char can't be implicitly converted.");
    quit(ERR_CHAR_TO_X, err_msg);
  }

  //All others can be implicit cast between themselves...

  char* identifier = value.stringValue;
  create_table_item(item, get_line_number(), NATUREZA_IDENTIFICADOR, type, get_type_size(type, value.stringValue),NULL, value, 0, 0, 0);
  if(add_item(tables, identifier, item) == -1){
    sprintf(err_msg, "line %d: %s '%s' %s\n", get_line_number(),"Variable", identifier, "has already been declared");
    quit(ERR_DECLARED, err_msg);
  }

}
;

//TODO: ADICIONAR AS INFERENCIAS DE TIPO !!! -> done
//TODO: CHECAR TIPO DO USUARIO -> NAO FIZ -> eu fiz :D
attribution: identificador_accessor '=' expression
{
  $$ = MakeNode(AST_TYPE_ATTRIBUTION, NULL);
  InsertChild($$, $1);
  InsertChild($$, $3);
  
  tree_node_t * exprr = $3;

  token_type_t exp_type = CheckExpression($3);
  token_type_t receive_type;

  char *v_name;
  if ($1->first_child)
    v_name = ((valor_lexico_t *)$1->first_child->value)->value.stringValue;
  else
    v_name = ((valor_lexico_t *)$1->value)->value.stringValue;

  symbol_table_t *t = find_item(tables, v_name);
  if(t != NULL) {
    receive_type = ((symbol_table_item_t *)t->item)->type;
    if(receive_type == AST_TYPE_CLASS && exp_type != AST_TYPE_CLASS){
      char* target_name = ((valor_lexico_t *)$1->first_child->brother_next->value)->value.stringValue;
      arg_list_t* fields = find_item(tables, t->item->value.stringValue)->item->arg_list;
      for(; fields!=NULL; fields=fields->next){
        if(strcmp(fields->field_name, target_name) == 0)
          receive_type=fields->type;
      }
    }
  }

  if ((exp_type == AST_TYPE_CLASS && receive_type != AST_TYPE_CLASS) || (exp_type != AST_TYPE_CLASS && receive_type == AST_TYPE_CLASS)){
    sprintf(err_msg, "line %d: %s\n", get_line_number(),"Custom types can't be implicitly converted.");
    quit(ERR_USER_TO_X, err_msg);
  }

  if (exp_type == AST_TYPE_CHAR && receive_type != AST_TYPE_CHAR) {
    sprintf(err_msg, "line %d: %s\n", get_line_number(),"Can't convert to char.");
    quit(ERR_CHAR_TO_X, err_msg);
  }

  if(exp_type == AST_TYPE_STRING && receive_type != AST_TYPE_STRING) {
    sprintf(err_msg, "line %d: %s\n", get_line_number(),"Can't convert to string");
    quit(ERR_STRING_TO_X, err_msg);
  }

  if(exp_type != AST_TYPE_STRING && receive_type == AST_TYPE_STRING) {
      sprintf(err_msg, "line %d: %s\n", get_line_number(),"String can't be implicitly converted.");
      quit(ERR_WRONG_TYPE, err_msg);
  }

  if(exp_type != AST_TYPE_CHAR && receive_type == AST_TYPE_CHAR) {
    sprintf(err_msg, "line %d: %s\n", get_line_number(),"Char can't be implicitly converted.");
    quit(ERR_WRONG_TYPE, err_msg);
  }


  if(exp_type != receive_type && exp_type == AST_TYPE_FLOAT || exp_type == AST_TYPE_INT || exp_type == AST_TYPE_BOOL && receive_type == AST_TYPE_FLOAT || receive_type == AST_TYPE_INT || receive_type == AST_TYPE_BOOL)
    $$->implicit_conversion = receive_type;
}
;

input: TK_PR_INPUT expression
{
  $$ = MakeNode(AST_TYPE_INPUT, NULL);
  InsertChild($$, $2);

  if( ((valor_lexico_t*)$2->value)->type != AST_TYPE_IDENTIFICATOR ) {
    sprintf(err_msg, "line %d: %s\n", get_line_number(),"Input parameter should be a declared vairable.");
    quit(ERR_WRONG_PAR_INPUT, err_msg);
  }

  symbol_table_t *st = find_item(tables, ((valor_lexico_t*)$2->value)->value.stringValue);

  if (st == NULL ) {
    sprintf(err_msg, "line %d: %s\n", get_line_number(),"Input parameter should be a declared vairable.");
    quit(ERR_UNDECLARED, err_msg);
  }
};

output: TK_PR_OUTPUT expression_list  {
  $$ = MakeNode(AST_TYPE_OUTPUT, NULL); InsertChild($$, $2); 

  tree_node_t *t = $2->first_child;
  symbol_table_t *st;

  token_type_t type;
  while(t != NULL) {
    type = ((valor_lexico_t*)t->value)->type;

    if( type != AST_TYPE_LITERAL_STRING
       && (type < AST_TYPE_ADD || type > AST_TYPE_NEGATIVE)
       && type != AST_TYPE_LITERAL_INT
       && type != AST_TYPE_LITERAL_FLOAT
       && type != AST_TYPE_LITERAL_BOOL
       && type != AST_TYPE_IDENTIFICATOR) {
      sprintf(err_msg, "line %d: %s\n", get_line_number(),"Output parameter should be a string or aritmetic expression.");
      quit(ERR_WRONG_PAR_OUTPUT, err_msg);
    }

    if (type == AST_TYPE_IDENTIFICATOR) {
      st = find_item(tables, ((valor_lexico_t*)t->value)->value.stringValue);
      if(st == NULL) {
        sprintf(err_msg, "line %d: %s\n", get_line_number(),"Output parameter not declared");
        quit(ERR_UNDECLARED, err_msg);
      }

      if(st->item->type == AST_TYPE_CHAR) {
        sprintf(err_msg, "line %d: %s\n", get_line_number(),"Output parameter should not be char or custom type");
        quit(ERR_WRONG_PAR_OUTPUT, err_msg);
      }
    }

    t = t->brother_next;
  }
}
;

func_call: 
TK_IDENTIFICADOR '(' args ')'
{
  $$ = MakeNode(AST_TYPE_FUNCTION_CALL, NULL);
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $1));
  InsertChild($$, $3);

  symbol_table_t *st = find_item(tables, $1->value.stringValue);
  symbol_table_t *st_aux = NULL;
  tree_node_t *node;
  token_type_t aux_type;

  if(st == NULL) {
    sprintf(err_msg, "line %d: %s '%s' %s\n", get_line_number(),"Variable", $1->value.stringValue, "is not declared");
    quit(ERR_UNDECLARED, err_msg);
  }

  if(st->item->nature != NATUREZA_FUNCAO) {
    sprintf(err_msg, "line %d: %s '%s' %s\n", get_line_number(),"The called function", $1->value.stringValue, "is not a function");
    quit(ERR_VARIABLE, err_msg);
  }

  arg_list_t *params = st->item->arg_list;
  arg_list_t *params_aux = NULL;
  token_type_t type;
  int found;

  //Don't need to check if params exists here because it's checked in identificador_accessor
  if ( ((valor_lexico_t*)($3->value))->type == AST_TYPE_EXPRESSION_LIST) {
    node = $3->first_child;
    while(node != NULL) {
    
      token_type_t type = ((valor_lexico_t*)node->value)->type;

      switch(type) {
        case AST_TYPE_IDENTIFICATOR:
          st_aux = find_item(tables, ((valor_lexico_t*)(node->value))->value.stringValue);
          
          if(!is_compact(st_aux->item->type, params->type)) {
            sprintf(err_msg, "line %d: %s\n", get_line_number(),"Incompatible parameters");
            quit(ERR_WRONG_TYPE_ARGS, err_msg);
          } else if(st_aux->item->type == AST_TYPE_CLASS && params->type == AST_TYPE_CLASS) {
            if(strcmp(st_aux->item->value.stringValue, params->field_name) != 0) {
              sprintf(err_msg, "line %d: %s\n", get_line_number(),"Incompatible parameters on custom objects");
              quit(ERR_WRONG_TYPE_ARGS, err_msg);
            }
          }
        break;

        case AST_TYPE_LITERAL_BOOL:
        case AST_TYPE_LITERAL_INT:
        case AST_TYPE_LITERAL_CHAR:
        case AST_TYPE_LITERAL_FLOAT:
        case AST_TYPE_LITERAL_STRING:
          if(!is_compact(CheckExpression(node), params->type)) {
            sprintf(err_msg, "line %d: %s\n", get_line_number(),"Incompatible parameters");
            quit(ERR_WRONG_TYPE_ARGS, err_msg);
          } 
          break;

        case AST_TYPE_OBJECT:
          if (((valor_lexico_t*)node->first_child->value)->type == AST_TYPE_VECTOR) {
            st_aux = find_item(tables, ((valor_lexico_t*)(node->first_child->first_child->value))->value.stringValue);
          } else {
            st_aux = find_item(tables, ((valor_lexico_t*)(node->first_child->value))->value.stringValue);
          }
          st_aux = find_item(tables, st_aux->item->value.stringValue);
          params_aux = st_aux->item->arg_list;
          found = 0;
          while(params_aux != NULL) {

            if( strcmp (params_aux->field_name, ((valor_lexico_t*)(node->first_child->brother_next->value))->value.stringValue) == 0) {
              type = params_aux->type;
              found = 1;
              break;
            }
            params_aux = params_aux->next;
          }
          
          if(!is_compact(type, params->type)) {
            sprintf(err_msg, "line %d: %s\n", get_line_number(),"Incompatible parameters");
            quit(ERR_WRONG_TYPE_ARGS, err_msg);
          }
        break;

        case AST_TYPE_VECTOR:
          st_aux = find_item(tables, ((valor_lexico_t*)(node->first_child->value))->value.stringValue);
          
          if(!is_compact(st_aux->item->type, params->type)) {
            sprintf(err_msg, "line %d: %s\n", get_line_number(),"Incompatible parameters");
            quit(ERR_WRONG_TYPE_ARGS, err_msg);
          } else if(st_aux->item->type == AST_TYPE_CLASS && params->type == AST_TYPE_CLASS) {
            if(strcmp(st_aux->item->value.stringValue, params->field_name) != 0) {
              sprintf(err_msg, "line %d: %s\n", get_line_number(),"Incompatible parameters on custom objects");
              quit(ERR_WRONG_TYPE_ARGS, err_msg);
            }
          }
        break;
        case AST_TYPE_FUNCTION_CALL: 
        	aux_type = find_item(tables, ((valor_lexico_t*)node->first_child->value)->value.stringValue)->item->type;
        	if(params->type != aux_type){
        		sprintf(err_msg, "line %d: Expected type: %s. Received type: %s\n", get_line_number(), type_to_str(params->type), type_to_str(aux_type));
    			quit(ERR_WRONG_TYPE_ARGS, err_msg);
        	}
        break;
      }

      if(params->next == NULL && node->brother_next != NULL) {
        sprintf(err_msg, "line %d: %s\n", get_line_number(),"Too many arguments on function call");
        quit(ERR_EXCESS_ARGS, err_msg);
      }
      node = node->brother_next;
      params = params->next;
    }

    if(params != NULL) {
      sprintf(err_msg, "line %d: %s\n", get_line_number(),"Missing arguments on function call");
      quit(ERR_MISSING_ARGS, err_msg);
    }
  }

}
| TK_IDENTIFICADOR '(' ')'
{
  $$ = MakeNode(AST_TYPE_FUNCTION_CALL, NULL);
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $1));

  symbol_table_t *st = find_item(tables, $1->value.stringValue);

  if(st == NULL) {
    sprintf(err_msg, "line %d: %s '%s' %s\n", get_line_number(),"Function ", $1->value.stringValue, "is not declared");
    quit(ERR_UNDECLARED, err_msg);
  }

  if(st->item->nature != NATUREZA_FUNCAO) {
    sprintf(err_msg, "line %d: %s '%s' %s\n", get_line_number(),"The called function", $1->value.stringValue, "is not a function");
    if(st->item->is_vector) 
      quit(ERR_VECTOR, err_msg);
    else
      quit(ERR_VARIABLE, err_msg);
  }

  if(st->item->arg_list != NULL) {
    sprintf(err_msg, "line %d: %s '%s' %s\n", get_line_number(),"Too much parameters on function call ", $1->value.stringValue, ".");
    quit(ERR_MISSING_ARGS, err_msg);
  }
};

args: 
args ',' expression  {
  $$ = $1;
  InsertChild($$, $3);
}
| args ',' '.'       {
  $$ = $1;
  InsertChild($$, MakeNode(AST_TYPE_DOT, NULL));
}
| '.'                { 
	$$ = MakeNode(AST_TYPE_EXPRESSION_LIST, NULL); InsertChild($$, MakeNode(AST_TYPE_DOT, NULL));
	tree_node_t *ss = $$;

}
| expression         { $$ = MakeNode(AST_TYPE_EXPRESSION_LIST, NULL); InsertChild($$, $1); }
;

shift_cmd: 
identificador_accessor TK_OC_SL expression
{
  $$ = MakeNode(AST_TYPE_SL, NULL);
  InsertChild($$, $1);
  InsertChild($$, $3);
}
| identificador_accessor TK_OC_SR expression
{
  $$ = MakeNode(AST_TYPE_SR, NULL);
  InsertChild($$, $1);
  InsertChild($$, $3);
};

return: TK_PR_RETURN expression {
  $$ = MakeNode(AST_TYPE_RETURN, NULL); 
  InsertChild($$, $2);
  tree_node_t * test = $$;
  tree_node_t * test2 = $2;
  token_type_t type = CheckExpression($$);

  return_type=type;
  if(return_type == AST_TYPE_CLASS)
    func_return_type_name=find_item(tables, ((valor_lexico_t*)$2->value)->value.stringValue)->item->value.stringValue;
};

conditional_command: 
TK_PR_IF '(' expression ')' TK_PR_THEN command_block
{
  $$ = MakeNode(AST_TYPE_IF_ELSE, NULL);
  InsertChild($$, $3);
  InsertChild($$, $6);
}
| TK_PR_IF '(' expression ')' TK_PR_THEN command_block TK_PR_ELSE command_block
{
  $$ = MakeNode(AST_TYPE_IF_ELSE, NULL);
  InsertChild($$, $3);
  InsertChild($$, $6);
  InsertChild($$, $8);
}
;

foreach:  TK_PR_FOREACH '(' identificador_accessor ':' expression_list ')' command_block
{
  $$ = MakeNode(AST_TYPE_FOREACH, NULL);
  InsertChild($$, $3);
  InsertChild($$, $5);
  InsertChild($$, $7);
};

for: TK_PR_FOR '(' for_command_list ':' expression ':' for_command_list ')' command_block
{
  $$ = MakeNode(AST_TYPE_FOR, NULL);
  InsertChild($$, $3);
  InsertChild($$, $5);
  InsertChild($$, $7);
  InsertChild($$, $9);
};

while_do: TK_PR_WHILE '(' expression ')' TK_PR_DO command_block
{
  $$ = MakeNode(AST_TYPE_WHILE_DO, NULL);
  InsertChild($$, $3);
  InsertChild($$, $6);
};

do_while: TK_PR_DO  command_block TK_PR_WHILE '(' expression ')'
{
  $$ = MakeNode(AST_TYPE_DO_WHILE, NULL);
  InsertChild($$, $2);
  InsertChild($$, $5);
};

pipe_command:  
pipe_rec TK_OC_FORWARD_PIPE func_call
{
  $$ = MakeNode(AST_TYPE_FOWARD_PIPE, NULL);
  InsertChild($$, $1);
  InsertChild($$, $3);
  $$->node_type = CheckExpression($$);
  tree_node_t * ss=$$;
  token_type_t dot_type = get_next_dot_proposed_type($3);
  token_type_t pipe_rec_type = CheckExpression($1);
  if(dot_type != AST_TYPE_NULL && pipe_rec_type != dot_type){
  	sprintf(err_msg, "line %d: Expected type: %s. Received type: %s\n", get_line_number(), type_to_str(dot_type), type_to_str(pipe_rec_type));
    quit(ERR_WRONG_TYPE_ARGS, err_msg);
  }
}
| pipe_rec TK_OC_BASH_PIPE func_call
{
  $$ = MakeNode(AST_TYPE_BASH_PIPE, NULL);
  InsertChild($$, $1);
  InsertChild($$, $3);
  $$->node_type = CheckExpression($$);
  tree_node_t * ss=$$;
  token_type_t dot_type = get_next_dot_proposed_type($3);
  token_type_t pipe_rec_type = CheckExpression($1);
  if(dot_type != AST_TYPE_NULL && pipe_rec_type != dot_type){
  	sprintf(err_msg, "line %d: Expected type: %s. Received type: %s\n", get_line_number(), type_to_str(dot_type), type_to_str(pipe_rec_type));
    quit(ERR_WRONG_TYPE_ARGS, err_msg);
  }
};

pipe_rec:  
pipe_rec TK_OC_FORWARD_PIPE func_call
{
  $$ = MakeNode(AST_TYPE_FOWARD_PIPE, NULL);
  InsertChild($$, $1);
  InsertChild($$, $3);
  $$->node_type = CheckExpression($$);
  tree_node_t * ss=$$;
  token_type_t dot_type = get_next_dot_proposed_type($3);
  token_type_t pipe_rec_type = CheckExpression($1);
  if(dot_type != AST_TYPE_NULL && pipe_rec_type != dot_type){
  	sprintf(err_msg, "line %d: Expected type: %s. Received type: %s\n", get_line_number(), type_to_str(dot_type), type_to_str(pipe_rec_type));
    quit(ERR_WRONG_TYPE_ARGS, err_msg);
  }
}
| pipe_rec TK_OC_BASH_PIPE func_call
{
  $$ = MakeNode(AST_TYPE_BASH_PIPE, NULL);
  InsertChild($$, $1);
  InsertChild($$, $3);
  $$->node_type = CheckExpression($$);
  token_type_t dot_type = get_next_dot_proposed_type($3);
  token_type_t pipe_rec_type = CheckExpression($1);
  if(dot_type != AST_TYPE_NULL && pipe_rec_type != dot_type){
  	sprintf(err_msg, "line %d: Expected type: %s. Received type: %s\n", get_line_number(), type_to_str(dot_type), type_to_str(pipe_rec_type));
    quit(ERR_WRONG_TYPE_ARGS, err_msg);
  }
}
| func_call
{
  $$ = $1;
};

switch: TK_PR_SWITCH '(' expression ')' command_block
{
  $$ = MakeNode(AST_TYPE_SWITCH, NULL);
  InsertChild($$, $3);
  InsertChild($$, $5);
};

expression_list: 
expression_list ',' expression { 
  $$ = $1;
  InsertChild($$, $3);
}
| expression                   { $$ = MakeNode(AST_TYPE_EXPRESSION_LIST, NULL), InsertChild($$, $1); }
;
expression:  
'(' expression ')'        { $$ = $2; CheckExpression($$); }
| identificador_accessor  { $$ = $1; CheckExpression($$); }
| '+' expression          { $$ = $2; CheckExpression($$);} //TODO
| '-' expression          { $$ = MakeNode(AST_TYPE_NEGATIVE, NULL); InsertChild($$, $2); CheckExpression($$);} //TODO
| '!' expression          { $$ = MakeNode(AST_TYPE_NEGATE, NULL); InsertChild($$, $2); CheckExpression($$);} //TODO
| '&' expression          { $$ = MakeNode(AST_TYPE_ADDRESS, NULL); InsertChild($$, $2); CheckExpression($$);} //TODO
| '*' expression          { $$ = MakeNode(AST_TYPE_POINTER, NULL); InsertChild($$, $2); CheckExpression($$);} //TODO
| '?' expression          { $$ = MakeNode(AST_TYPE_QUESTION_MARK, NULL); InsertChild($$, $2); CheckExpression($$);} //TODO
| '#' expression          { $$ = MakeNode(AST_TYPE_HASHTAG, NULL); InsertChild($$, $2); CheckExpression($$);} //TODO
| expression '*' expression                 {$$ = MakeNode(AST_TYPE_MUL, NULL);InsertChild($$, $1);InsertChild($$, $3); CheckExpression($$);}
| expression '/' expression                 {$$ = MakeNode(AST_TYPE_DIV, NULL);InsertChild($$, $1);InsertChild($$, $3); CheckExpression($$);}
| expression '%' expression                 {$$ = MakeNode(AST_TYPE_REST, NULL);InsertChild($$, $1);InsertChild($$, $3); CheckExpression($$);}
| expression '+' expression                 {$$ = MakeNode(AST_TYPE_ADD, NULL);InsertChild($$, $1);InsertChild($$, $3); CheckExpression($$);}
| expression '-' expression                 {$$ = MakeNode(AST_TYPE_SUB, NULL);InsertChild($$, $1);InsertChild($$, $3); CheckExpression($$);}
| expression '<' expression                 {$$ = MakeNode(AST_TYPE_LS, NULL);InsertChild($$, $1);InsertChild($$, $3); CheckExpression($$);}
| expression '|' expression                 {$$ = MakeNode(AST_TYPE_BW_OR, NULL);InsertChild($$, $1);InsertChild($$, $3); CheckExpression($$);}
| expression '&' expression                 {$$ = MakeNode(AST_TYPE_BW_AND, NULL);InsertChild($$, $1);InsertChild($$, $3); CheckExpression($$);}
| expression '^' expression                 {$$ = MakeNode(AST_TYPE_BW_XOR, NULL);InsertChild($$, $1);InsertChild($$, $3); CheckExpression($$);}
| expression TK_OC_LE expression            {$$ = MakeNode(AST_TYPE_LE, NULL);InsertChild($$, $1);InsertChild($$, $3); CheckExpression($$);}
| expression '>' expression                 {$$ = MakeNode(AST_TYPE_GR, NULL);InsertChild($$, $1);InsertChild($$, $3); CheckExpression($$);}
| expression TK_OC_GE expression            {$$ = MakeNode(AST_TYPE_GE, NULL);InsertChild($$, $1);InsertChild($$, $3); CheckExpression($$);}
| expression TK_OC_EQ expression            {$$ = MakeNode(AST_TYPE_EQ, NULL);InsertChild($$, $1);InsertChild($$, $3); CheckExpression($$);}
| expression TK_OC_NE expression            {$$ = MakeNode(AST_TYPE_NE, NULL);InsertChild($$, $1);InsertChild($$, $3); CheckExpression($$);}
| expression TK_OC_AND expression           {$$ = MakeNode(AST_TYPE_AND, NULL);InsertChild($$, $1);InsertChild($$, $3); CheckExpression($$);}
| expression TK_OC_OR expression            {$$ = MakeNode(AST_TYPE_OR, NULL);InsertChild($$, $1);InsertChild($$, $3); CheckExpression($$);}
| expression '?' expression ':' expression  {$$ = MakeNode(AST_TYPE_TERNARY, NULL);InsertChild($$, $1);InsertChild($$, $3);InsertChild($$, $5);} //TODO
| pipe_command                              {$$ = $1; CheckExpression($$);} //TODO
| func_call                                 {$$ = $1; CheckExpression($$);}
| tk_lit                                    {$$ = $1; CheckExpression($$);}
;

%%

tree_node_t* MakeNode(token_type_t type, valor_lexico_t* valor_lexico) {
  
  valor_lexico_t *vl;
  
  if(valor_lexico == NULL) {
     vl = (valor_lexico_t*)malloc(sizeof(valor_lexico_t));
     vl->type = type;
  } else {
    vl = valor_lexico;
  }

  vl->line = 0;
  return make_node(vl);
}

void InsertChild(tree_node_t *father, tree_node_t *children) {
  if(children == NULL)
    return;

  insert_child(father, children);
}

token_type_t CheckExpression(tree_node_t *node) {

  valor_lexico_t *vl = node->value;
  token_type_t first_type;
  token_type_t second_type;
  token_type_t aux;
  symbol_table_t *st;
  arg_list_t *params_aux;
  int found;
  token_type_t type;
  char *name;

  if(node->node_type != AST_TYPE_NULL)  // if node_type is not default
  	return node->node_type;

  switch(vl->type) {
    case AST_TYPE_LITERAL_CHAR: return AST_TYPE_CHAR; break;
    case AST_TYPE_LITERAL_BOOL: return AST_TYPE_BOOL; break;
    case AST_TYPE_LITERAL_FLOAT: return AST_TYPE_FLOAT; break;
    case AST_TYPE_LITERAL_INT: return AST_TYPE_INT; break;
    case AST_TYPE_LITERAL_STRING: return AST_TYPE_STRING; break;
    

    //TODO: CHECK BITWISE OPERATORS !!!
    case AST_TYPE_LS:
    case AST_TYPE_LE:
    case AST_TYPE_GR:
    case AST_TYPE_GE:
    case AST_TYPE_EQ:
    case AST_TYPE_NE:
    case AST_TYPE_AND:
    case AST_TYPE_OR:
      first_type = CheckExpression(node->first_child);
      second_type = CheckExpression(node->first_child->brother_next);
      if( (first_type  == AST_TYPE_INT || first_type ==  AST_TYPE_FLOAT || first_type  == AST_TYPE_BOOL) && 
          (second_type == AST_TYPE_INT || second_type == AST_TYPE_FLOAT || second_type == AST_TYPE_BOOL) ){
      
        if(first_type != AST_TYPE_BOOL)
        	node->first_child->implicit_conversion = AST_TYPE_BOOL;
       	if(second_type != AST_TYPE_BOOL)
        	node->first_child->brother_next->implicit_conversion = AST_TYPE_BOOL;

        node->node_type = AST_TYPE_BOOL;
        return AST_TYPE_BOOL;
      }
      sprintf(err_msg, "line %d: %s\n", get_line_number(), "Wrong type.");
      quit(ERR_WRONG_TYPE, err_msg);
      break;

    case AST_TYPE_MUL:
    case AST_TYPE_REST:
    case AST_TYPE_ADD:
    case AST_TYPE_SUB:
    case AST_TYPE_DIV:
      first_type = CheckExpression(node->first_child);
      second_type = CheckExpression(node->first_child->brother_next);
      

      if(first_type == AST_TYPE_CHAR || second_type == AST_TYPE_CHAR) {
        sprintf(err_msg, "line %d: %s\n", get_line_number(), "Wrong type 2.");
        quit(ERR_CHAR_TO_X, err_msg);
      } else if(first_type == AST_TYPE_STRING || second_type == AST_TYPE_STRING) {
        sprintf(err_msg, "line %d: %s\n", get_line_number(), "Wrong type 2.");
        quit(ERR_STRING_TO_X, err_msg);
      } else if(first_type == AST_TYPE_CLASS || second_type == AST_TYPE_CLASS) {
        sprintf(err_msg, "line %d: %s\n", get_line_number(), "Wrong type 2.");
        quit(ERR_USER_TO_X, err_msg);
      }


      if(first_type == second_type){
      	node->node_type = first_type;
      	return first_type;
      }


  	  if(first_type == AST_TYPE_FLOAT || second_type == AST_TYPE_FLOAT){
  	  	if(first_type != AST_TYPE_FLOAT)
  	  		node->first_child->implicit_conversion = AST_TYPE_FLOAT;
  	  	else
  	  		node->first_child->brother_next->implicit_conversion = AST_TYPE_FLOAT;

  	  	node->node_type = AST_TYPE_FLOAT;
  	  	return AST_TYPE_FLOAT;
  	  }

  	  if(first_type == AST_TYPE_INT || second_type == AST_TYPE_INT){
  	  	if(first_type != AST_TYPE_INT)
  	  		node->first_child->implicit_conversion = AST_TYPE_INT;
  	  	else
  	  		node->first_child->brother_next->implicit_conversion = AST_TYPE_INT;

  	  	node->node_type = AST_TYPE_INT;
  	  	return AST_TYPE_INT;
  	  }

      break;

    case AST_TYPE_IDENTIFICATOR:

      st = find_item(tables, ((valor_lexico_t *)node->value)->value.stringValue);
      if(st != NULL) {
      	node->node_type = ((symbol_table_item_t *)st->item)->type;
        return node->node_type;
      }
      else {
        sprintf(err_msg, "line %d: %s '%s' %s\n", get_line_number(),"Variable", ((valor_lexico_t *)node->value)->value.stringValue, "is not declared");
        quit(ERR_UNDECLARED, err_msg);
      }

      break;

	case AST_TYPE_BASH_PIPE:
		node->node_type = CheckExpression(node->first_child->brother_next);
		return node->node_type;
	  break;
    case AST_TYPE_VECTOR:
          st = find_item(tables, ((valor_lexico_t*)(node->first_child->value))->value.stringValue);
          if(st == NULL){
            sprintf(err_msg, "line %d: %s '%s' %s\n", get_line_number(),"Variable", ((valor_lexico_t*)(node->first_child->value))->value.stringValue, "is not declared");
            quit(ERR_UNDECLARED, err_msg);
          }
          node->node_type = st->item->type;
          return node->node_type;
    break;
    case AST_TYPE_OBJECT:
          if (((valor_lexico_t*)node->first_child->value)->type == AST_TYPE_VECTOR) {
            name=((valor_lexico_t*)(node->first_child->first_child->value))->value.stringValue;
            st = find_item(tables, name);
          } else {
            name = ((valor_lexico_t*)(node->first_child->value))->value.stringValue;
            st = find_item(tables, name);
          }
          if(st == NULL){
            sprintf(err_msg, "line %d: %s '%s' %s\n", get_line_number(),"Variable", name, "is not declared");
            quit(ERR_UNDECLARED, err_msg);
          }
          st = find_item(tables, st->item->value.stringValue);
          
          params_aux = st->item->arg_list;
          found = 0;
          while(params_aux != NULL) {

            if( strcmp (params_aux->field_name, ((valor_lexico_t*)(node->first_child->brother_next->value))->value.stringValue) == 0) {
              type = params_aux->type;
              found = 1;
              node->node_type = type;
              return type;
              break;
            }
            params_aux = params_aux->next;
          }
          if(!found) {
            sprintf(err_msg, "line %d: %s\n", get_line_number(),"Unknown field");
            quit(ERR_USER, err_msg);
          }
    break;

    case AST_TYPE_FUNCTION_CALL:
      st = find_item(tables, ((valor_lexico_t*)(node->first_child->value))->value.stringValue);
      node->node_type = st->item->type;
      return node->node_type;

    case AST_TYPE_RETURN:
      return CheckExpression(node->first_child);


    default: return vl->type;
  }
}

int get_type_size(token_type_t type, char* name) {
  switch(type) {
    case AST_TYPE_INT: return 4;
    case AST_TYPE_FLOAT: return 8;
    case AST_TYPE_BOOL: return 1;
    case AST_TYPE_CHAR: return 1;
    case AST_TYPE_STRING: return 0; //TODO: FIXMEEEE
    case AST_TYPE_IDENTIFICATOR: if(name == NULL) printf("ProgrammingError: get_type_size AST_TYPE_IDENTIFICATOR sem nome do identificador"); else return find_item(tables, name)->item->type_size;
  }
}

void create_global_value( valor_lexico_t *first, tree_node_t *second, int is_vector ) {
  
  char* identifier = first->value.stringValue, *aux_str;
  symbol_table_item_t *item = NULL;

  if(find_item(tables, identifier)) {
    sprintf(err_msg, "line %d: %s '%s' %s\n", get_line_number(),"Variable", identifier, "has already been declared");
    quit(ERR_DECLARED, err_msg);
  }

  token_type_t type = ((valor_lexico_t*)second->value)->type;

  item = (symbol_table_item_t *)malloc(sizeof(symbol_table_item_t));

  if(type == AST_TYPE_STATIC) {
    if (((valor_lexico_t*)second->first_child->value)->type == AST_TYPE_IDENTIFICATOR) {

      if(find_item(tables, ((valor_lexico_t*)second->first_child->value)->value.stringValue) == NULL) {
        sprintf(err_msg, "line %d: %s '%s' %s\n", get_line_number(),"Type", ((valor_lexico_t*)second->first_child->value)->value.stringValue, "has not been declared");
        quit(ERR_UNDECLARED, err_msg);
      } else {
        type=AST_TYPE_CLASS;
      }

      create_table_item(item, get_line_number(), NATUREZA_GLOBAL_VAR, type, get_type_size(type, NULL), NULL, ((valor_lexico_t*)second->first_child->value)->value, 0, 1, is_vector); //TODO: discover last 3 values from tree
    }
    else {
      type = ((valor_lexico_t*)second->first_child->value)->type;
      create_table_item(item, get_line_number(), NATUREZA_GLOBAL_VAR, type, get_type_size(type, NULL), NULL, ((valor_lexico_t*)second->value)->value, 0, 1, is_vector); //TODO: discover last 3 values from tree
    }
  } else {

    if(((valor_lexico_t*)second->value)->type == AST_TYPE_IDENTIFICATOR) {
      if(find_item(tables, ((valor_lexico_t*)second->value)->value.stringValue) == NULL) {
        sprintf(err_msg, "line %d: %s '%s' %s\n", get_line_number(),"Type", ((valor_lexico_t*)second->value)->value.stringValue, "has not been declared");
        quit(ERR_UNDECLARED, err_msg);
      } else {
        type=AST_TYPE_CLASS;
      }
    }

    create_table_item(item, get_line_number(), NATUREZA_GLOBAL_VAR, type, get_type_size(type, first->value.stringValue), NULL, first->value, 0, 0, is_vector); //TODO: discover last 3 values from tree
  }

  if(add_item(tables, identifier, item) == -1){
    sprintf(err_msg, "line %d: %s '%s' %s\n", get_line_number(),"Variable", identifier, "has already been declared");
    quit(ERR_DECLARED, err_msg);
  }
}

void find_in_object(valor_lexico_t *first, valor_lexico_t *second, int is_vector) {


  char* identifier = first->value.stringValue;
  symbol_table_t *st = find_item(tables, identifier);
  
  if( st == NULL) {
    sprintf(err_msg, "line %d: %s '%s' %s\n", get_line_number(),"Identificator", identifier, "has not been declared");
    quit(ERR_UNDECLARED, err_msg);
  }

  if(st->item->type != AST_TYPE_CLASS) {
    sprintf(err_msg, "line %d: %s\n", get_line_number(),"Can only access user type variables");
    quit(ERR_VARIABLE, err_msg);
  }

  if(is_vector && (st->item->is_vector <= 0)) {
    sprintf(err_msg, "line %d: %s %s\n", get_line_number(), identifier, "is not a vector");
    quit(ERR_VECTOR, err_msg);
  }

  symbol_table_t *st_type = find_item(tables, st->item->value.stringValue);

  if(st_type == NULL) {
    quit(-1, "Something went terrebly wrong validating fields");
  }

  int found = 0;
  arg_list_t *aux = st_type->item->arg_list;
  while(aux != NULL) {
    if (strcmp(aux->field_name, second->value.stringValue) == 0) {
      found = 1;
      break;
    }
    aux = aux->next;
  }

  if(!found) {
    sprintf(err_msg, "line %d: %s\n", get_line_number(), "User Class does not have such property.");
    quit(ERR_USER, err_msg);
  }
}

int is_compact(token_type_t t1, token_type_t t2) {
  if(t1 == AST_TYPE_INT && t2 == AST_TYPE_INT) return 1;
  if(t1 == AST_TYPE_INT && t2 == AST_TYPE_BOOL) return 1;
  if(t1 == AST_TYPE_INT && t2 == AST_TYPE_FLOAT) return 1;

  if(t1 == AST_TYPE_FLOAT && t2 == AST_TYPE_FLOAT) return 1;
  if(t1 == AST_TYPE_FLOAT && t2 == AST_TYPE_INT) return 1;
  if(t1 == AST_TYPE_FLOAT && t2 == AST_TYPE_BOOL) return 1;
  
  if(t1 == AST_TYPE_BOOL && t2 == AST_TYPE_BOOL) return 1;
  if(t1 == AST_TYPE_BOOL && t2 == AST_TYPE_INT) return 1;
  if(t1 == AST_TYPE_BOOL && t2 == AST_TYPE_FLOAT) return 1;

  if(t1 == AST_TYPE_CHAR && t2 == AST_TYPE_CHAR) return 1;
  if(t1 == AST_TYPE_STRING && t2 == AST_TYPE_STRING) return 1;

  if(t1 == AST_TYPE_CLASS && t2 == AST_TYPE_CLASS) return 1;
  return 0;
}

const char* type_to_str(token_type_t tkn){
  switch(tkn){
      case AST_TYPE_NULL: return "AST_TYPE_NULL";
      break;
      case AST_TYPE_INT: return "AST_TYPE_INT";
      break;
      case AST_TYPE_FLOAT: return "AST_TYPE_FLOAT";
      break;
      case AST_TYPE_BOOL: return "AST_TYPE_BOOL";
      break;
      case AST_TYPE_CHAR: return "AST_TYPE_CHAR";
      break;
      case AST_TYPE_STRING: return "AST_TYPE_STRING";
      break;
      case AST_TYPE_CLASS:
      case AST_TYPE_IDENTIFICATOR:
        return "AST_TYPE_CLASS";
        break;
      }
}

token_type_t get_next_dot_proposed_type(tree_node_t* func_call){
	char* func_name = ((valor_lexico_t*) func_call->first_child->value)->value.stringValue;
	tree_node_t *aux = func_call->first_child->brother_next->first_child; // got first of linked argument list
	token_type_t dot_type = AST_TYPE_NULL;
	int counter = 1;
	arg_list_t* func_args;
	while(aux != NULL && dot_type == AST_TYPE_NULL){
		if(((valor_lexico_t*) aux->value)->type == AST_TYPE_DOT){
			((valor_lexico_t*) aux->value)->type=AST_TYPE_USED_DOT; // used dot as it has been "filled" 
			func_args = find_item(tables, func_name)->item->arg_list;
			for(int i=counter; i > 1; i--){ func_args = func_args->next; }
			dot_type = func_args->type;
		}
		aux = aux->brother_next;
		counter++;
	}

	return dot_type;
}

// symbol_table_t* get_table(void) {
//   if(outer_table == NULL) {
//     outer_table = (symbol_table_t*)malloc(sizeof(symbol_table_t));
//   }
//   return outer_table;
// }