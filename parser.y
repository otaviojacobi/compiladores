%code requires {
  #include "valor_lexico.h"
  #include "stdio.h"
  #include "tree.h"
  #include "stack.h"
  #include "err.h"
}

%{
  #include "tree.h"
  #include "stack.h"
  #include "err.h"
  extern tree_node_t *arvore;
  extern stack_t *tables;
  int yylex(void);
  void yyerror (char const *s);
  tree_node_t* MakeNode(token_type_t type, valor_lexico_t* valor_lexico);
  void InsertChild(tree_node_t *father, tree_node_t *children);
  token_type_t CheckExpression(tree_node_t *node);
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
             | %empty { $$ = NULL; }
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
}
| TK_IDENTIFICADOR '$' TK_IDENTIFICADOR                      
{
  $$ = MakeNode(AST_TYPE_OBJECT, NULL);
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $1));
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $3));
}
| TK_IDENTIFICADOR '[' expression ']'                        
{
  $$ = MakeNode(AST_TYPE_VECTOR, NULL);
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $1));
  InsertChild($$, $3);
}
| TK_IDENTIFICADOR '[' expression ']' '$' TK_IDENTIFICADOR   
{
  tree_node_t* vector = MakeNode(AST_TYPE_VECTOR, NULL);
  InsertChild(vector, MakeNode(AST_TYPE_IDENTIFICATOR, $1));
  InsertChild(vector, $3);

  $$ = MakeNode(AST_TYPE_OBJECT, NULL);
  InsertChild($$, vector);
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $6));
}
;

new_type_decl: TK_PR_CLASS TK_IDENTIFICADOR '[' field_list ']' ';' {
  $$ = MakeNode(AST_TYPE_CLASS, NULL);
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $2));
  InsertChild($$, $4);
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
}
| TK_IDENTIFICADOR '[' TK_LIT_INT ']' gv_type';' {
  $$ = MakeNode(AST_TYPE_GLOBAL_VAR, NULL);
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $1));
  InsertChild($$, MakeNode(AST_TYPE_LITERAL_INT, $3));
  InsertChild($$, $5);
};

gv_type: TK_PR_STATIC std_type { 
  $$ = MakeNode(AST_TYPE_STATIC, NULL); 
  InsertChild($$, $2); 
}
| std_type { $$ = $1; }
| TK_PR_STATIC TK_IDENTIFICADOR { 
  $$ = MakeNode(AST_TYPE_STATIC, NULL);
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $2)); }
| TK_IDENTIFICADOR { $$ = MakeNode(AST_TYPE_IDENTIFICATOR, $1); }
;

func: func_head command_block { 
  $$ = MakeNode(AST_TYPE_FUNCTION, NULL); 
  InsertChild($$, $1); 
  InsertChild($$, $2); 
}
| TK_PR_STATIC func_head command_block {
  $$ = MakeNode(AST_TYPE_STATIC, NULL);
  tree_node_t* aux = MakeNode(AST_TYPE_FUNCTION, NULL); 
  InsertChild(aux, $2); 
  InsertChild(aux, $3);
  InsertChild($$, aux);
};

func_head:  std_type_node TK_IDENTIFICADOR param_list
{
  $$ = MakeNode(AST_TYPE_FUNCTION_HEAD, NULL);
  InsertChild($$, $1);
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $2));
  InsertChild($$, $3);
}
| TK_IDENTIFICADOR TK_IDENTIFICADOR param_list
{
  $$ = MakeNode(AST_TYPE_FUNCTION_HEAD, NULL);
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $1));
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $2));
  InsertChild($$, $3);
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

command_block: '{' command_seq '}' { $$ = MakeNode(AST_TYPE_COMMAND_BLOCK, NULL); InsertChild($$, $2); } | '{' '}' { $$ = MakeNode(AST_TYPE_COMMAND_BLOCK, NULL); };

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
}
| local_var_static_consumed { $$ = $1; };
local_var_static_consumed: TK_PR_CONST local_var_const_consumed { 
  $$ = MakeNode(AST_TYPE_CONST, NULL);
  InsertChild($$, $2);
} 
| local_var_const_consumed { $$ = $1; };

local_var_const_consumed:  
std_type TK_IDENTIFICADOR { 
  $$ = MakeNode(AST_TYPE_DECLR, NULL); 
  InsertChild($$, $1);
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $2));
}
| TK_IDENTIFICADOR TK_IDENTIFICADOR { 
  $$ = MakeNode(AST_TYPE_DECLR, NULL); 
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $1));
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $2));
}
| std_type TK_IDENTIFICADOR TK_OC_LE TK_IDENTIFICADOR
{
  $$ = MakeNode(AST_TYPE_DECLR, NULL);
  InsertChild($$, $1);
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $2));
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $4));
}
| std_type TK_IDENTIFICADOR TK_OC_LE tk_lit
{
  $$ = MakeNode(AST_TYPE_DECLR, NULL);
  InsertChild($$, $1);
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $2));
  InsertChild($$, $4);
}
;

attribution: identificador_accessor '=' expression
{
  $$ = MakeNode(AST_TYPE_ATTRIBUTION, NULL);
  InsertChild($$, $1);
  InsertChild($$, $3);
}
;

input: TK_PR_INPUT expression         {$$ = MakeNode(AST_TYPE_INPUT, NULL); InsertChild($$, $2);};
output: TK_PR_OUTPUT expression_list  {$$ = MakeNode(AST_TYPE_OUTPUT, NULL); InsertChild($$, $2);};

func_call: 
TK_IDENTIFICADOR '(' args ')'
{
  $$ = MakeNode(AST_TYPE_FUNCTION_CALL, NULL);
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $1));
  InsertChild($$, $3);
}
| TK_IDENTIFICADOR '(' ')'
{
  $$ = MakeNode(AST_TYPE_FUNCTION_CALL, NULL);
  InsertChild($$, MakeNode(AST_TYPE_IDENTIFICATOR, $1));
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
| '.'                { $$ = MakeNode(AST_TYPE_EXPRESSION_LIST, NULL); InsertChild($$, MakeNode(AST_TYPE_DOT, NULL));}
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

return: TK_PR_RETURN expression {$$ = MakeNode(AST_TYPE_RETURN, NULL); InsertChild($$, $2);};

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
}
| pipe_rec TK_OC_BASH_PIPE func_call
{
  $$ = MakeNode(AST_TYPE_BASH_PIPE, NULL);
  InsertChild($$, $1);
  InsertChild($$, $3);
};

pipe_rec:  
pipe_rec TK_OC_FORWARD_PIPE func_call
{
  $$ = MakeNode(AST_TYPE_FOWARD_PIPE, NULL);
  InsertChild($$, $1);
  InsertChild($$, $3);
}
| pipe_rec TK_OC_BASH_PIPE func_call
{
  $$ = MakeNode(AST_TYPE_BASH_PIPE, NULL);
  InsertChild($$, $1);
  InsertChild($$, $3);
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
| '+' expression          { $$ = $2; CheckExpression($$);}
| '-' expression          { $$ = MakeNode(AST_TYPE_NEGATIVE, NULL); InsertChild($$, $2); CheckExpression($$);}
| '!' expression          { $$ = MakeNode(AST_TYPE_NEGATE, NULL); InsertChild($$, $2); CheckExpression($$);}
| '&' expression          { $$ = MakeNode(AST_TYPE_ADDRESS, NULL); InsertChild($$, $2); CheckExpression($$);}
| '*' expression          { $$ = MakeNode(AST_TYPE_POINTER, NULL); InsertChild($$, $2); CheckExpression($$);}
| '?' expression          { $$ = MakeNode(AST_TYPE_QUESTION_MARK, NULL); InsertChild($$, $2); CheckExpression($$);}
| '#' expression          { $$ = MakeNode(AST_TYPE_HASHTAG, NULL); InsertChild($$, $2); CheckExpression($$);}
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
| expression '?' expression ':' expression  {$$ = MakeNode(AST_TYPE_TERNARY, NULL);InsertChild($$, $1);InsertChild($$, $3);InsertChild($$, $5);}
| pipe_command                              {$$ = $1; CheckExpression($$);}
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
          (second_type == AST_TYPE_INT || second_type == AST_TYPE_FLOAT || second_type == AST_TYPE_BOOL) )
        return AST_TYPE_BOOL;
      quit(ERR_WRONG_TYPE, "Wrong type.");
      break;

    case AST_TYPE_MUL:
    case AST_TYPE_REST:
    case AST_TYPE_ADD:
    case AST_TYPE_SUB:
    case AST_TYPE_DIV:
      first_type = CheckExpression(node->first_child);
      second_type = CheckExpression(node->first_child->brother_next);
        
      if(first_type == AST_TYPE_BOOL && second_type == AST_TYPE_BOOL)
        return AST_TYPE_BOOL;

      if( (first_type == AST_TYPE_INT && second_type == AST_TYPE_INT) ||
          (first_type == AST_TYPE_BOOL && second_type == AST_TYPE_INT) ||
          (first_type == AST_TYPE_INT && second_type == AST_TYPE_BOOL) )
        return AST_TYPE_INT;

      if( (first_type == AST_TYPE_FLOAT && second_type == AST_TYPE_FLOAT) ||
          (first_type == AST_TYPE_BOOL && second_type == AST_TYPE_FLOAT) ||
          (first_type == AST_TYPE_FLOAT && second_type == AST_TYPE_BOOL) ||
          (first_type == AST_TYPE_INT && second_type == AST_TYPE_FLOAT) ||
          (first_type == AST_TYPE_FLOAT && second_type == AST_TYPE_INT) )
        return AST_TYPE_FLOAT;


      quit(ERR_WRONG_TYPE, "Wrong type.");
      break;

  }

}