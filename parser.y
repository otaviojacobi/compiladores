%code requires {
  #include "valor_lexico.h"
  #include "stdio.h"
  #include "tree.h"
}

%{
  #include "tree.h"
  tree_node_t *ast_head;
  int yylex(void);
  void yyerror (char const *s);
  tree_node_t* MakeNode(token_type_t type, valor_lexico_t* valor_lexico);
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
%type <valor_lexico> func_head


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

programa: programa_rec {ast_head = MakeNode(AST_TYPE_PROGRAM_START, NULL); insert_child(ast_head, $1);}
;

programa_rec:  programa_rec new_type_decl { $$ = $1; }
             | programa_rec global_var_decl { $$ = $1; }
             | programa_rec func { insert_child($2, $1); $$ = $2; }
             | %empty { $$ = NULL; }
;

std_type: TK_PR_INT | TK_PR_FLOAT | TK_PR_BOOL | TK_PR_CHAR | TK_PR_STRING;
protection: TK_PR_PRIVATE | TK_PR_PUBLIC | TK_PR_PROTECTED;


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
  insert_child($$, MakeNode(AST_TYPE_IDENTIFICATOR, $1));
  insert_child($$, MakeNode(AST_TYPE_IDENTIFICATOR, $3));
}
| TK_IDENTIFICADOR '[' expression ']'                        
{
  $$ = MakeNode(AST_TYPE_VECTOR, NULL);
  insert_child($$, MakeNode(AST_TYPE_IDENTIFICATOR, $1));
  insert_child($$, $3);
}
| TK_IDENTIFICADOR '[' expression ']' '$' TK_IDENTIFICADOR   
{
  $$ = MakeNode(AST_TYPE_ATTRIBUTION, NULL);

  tree_node_t* vector = MakeNode(AST_TYPE_VECTOR, NULL);
  insert_child(vector, MakeNode(AST_TYPE_IDENTIFICATOR, $1));
  insert_child(vector, $3);

  $$ = MakeNode(AST_TYPE_OBJECT, NULL);
  insert_child($$, vector);
  insert_child($$, MakeNode(AST_TYPE_IDENTIFICATOR, $6));
}
;

new_type_decl: TK_PR_CLASS TK_IDENTIFICADOR '[' field_list ']' ';';
field_list: field_list ':' field | field;
field: protection std_type TK_IDENTIFICADOR | std_type TK_IDENTIFICADOR;

global_var_decl: TK_IDENTIFICADOR gv_type ';' | TK_IDENTIFICADOR '[' TK_LIT_INT ']' gv_type';';
gv_type: TK_PR_STATIC std_type | std_type | TK_PR_STATIC TK_IDENTIFICADOR | TK_IDENTIFICADOR;

func: func_head command_block { $$ = MakeNode(AST_TYPE_FUNCTION, $1); insert_child($$, $2); };

func_head:  std_type TK_IDENTIFICADOR param_list
{
  $$ = $2;
}
| TK_PR_STATIC std_type TK_IDENTIFICADOR param_list
{
  $$ = $3;
}
| TK_IDENTIFICADOR TK_IDENTIFICADOR param_list
{
  $$ = $2; 
}
| TK_PR_STATIC TK_IDENTIFICADOR TK_IDENTIFICADOR param_list
{
  $$ = $3;
}
;

param_list: '(' parameters ')' | '(' ')';
parameters: parameters ',' param | param;
param:  std_type TK_IDENTIFICADOR 
      | TK_PR_CONST std_type TK_IDENTIFICADOR
      | TK_IDENTIFICADOR TK_IDENTIFICADOR
      | TK_PR_CONST TK_IDENTIFICADOR TK_IDENTIFICADOR
;

command_block: '{' command_seq '}' { $$ = $2; }| '{' '}' { $$ = NULL; };

command_seq: command_seq simple_command
{
  if($2) {
    insert_child($2, $1); 
    $$ = $2;
  } else {
    $$ = $1;
  }
}
| simple_command
{
  $$ = $1;
}
;

for_command_list: 
for_command_list ',' simple_command_for 
{
  if($3) {
    insert_child($3, $1);
    $$ = $3;
  } else {
    $$ = $1;
  }
}
| simple_command_for
{
  $$ = $1;
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

simple_command_for:  command_block ';'       { $$ = $1; }
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
;

break: TK_PR_BREAK        { $$ = MakeNode(AST_TYPE_BREAK, NULL); };
continue: TK_PR_CONTINUE  { $$ = MakeNode(AST_TYPE_CONTINUE, NULL); };

case: TK_PR_CASE TK_LIT_INT ':' command_block 
{
  $$ = MakeNode(AST_TYPE_CASE, NULL);
  insert_child($$, MakeNode(AST_TYPE_LITERAL_INT, $2));
  insert_child($$, $4);
};

local_var_decl: TK_PR_STATIC local_var_static_consumed { $$ = $2; }| local_var_static_consumed { $$ = $1; };
local_var_static_consumed: TK_PR_CONST local_var_const_consumed { $$ = $2; } | local_var_const_consumed { $$ = $1; };
local_var_const_consumed:  
std_type TK_IDENTIFICADOR { $$ = NULL; }
| TK_IDENTIFICADOR TK_IDENTIFICADOR { $$ = NULL; }
| std_type TK_IDENTIFICADOR TK_OC_LE TK_IDENTIFICADOR
{
  $$ = MakeNode(AST_TYPE_DECLR_ON_ATTR, NULL);
  insert_child($$, MakeNode(AST_TYPE_IDENTIFICATOR, $2));
  insert_child($$, MakeNode(AST_TYPE_IDENTIFICATOR, $4));
}
| std_type TK_IDENTIFICADOR TK_OC_LE tk_lit
{
  $$ = MakeNode(AST_TYPE_DECLR_ON_ATTR, NULL);
  insert_child($$, MakeNode(AST_TYPE_IDENTIFICATOR, $2));
  insert_child($$, $4);
}
;

attribution: identificador_accessor '=' expression
{
  $$ = MakeNode(AST_TYPE_ATTRIBUTION, NULL);
  insert_child($$, $1);
  insert_child($$, $3);
}
;

input: TK_PR_INPUT expression         {$$ = MakeNode(AST_TYPE_INPUT, NULL); insert_child($$, $2);};
output: TK_PR_OUTPUT expression_list  {$$ = MakeNode(AST_TYPE_OUTPUT, NULL); insert_child($$, $2);};

func_call: 
TK_IDENTIFICADOR '(' args ')'
{
  $$ = MakeNode(AST_TYPE_FUNCTION_CALL, NULL);
  insert_child($$, MakeNode(AST_TYPE_IDENTIFICATOR, $1));
  insert_child($$, $3);
}
| TK_IDENTIFICADOR '(' ')'
{
  $$ = MakeNode(AST_TYPE_FUNCTION_CALL, NULL);
  insert_child($$, MakeNode(AST_TYPE_IDENTIFICATOR, $1));
};

args: 
args ',' expression  {$$ = $3;insert_child($$, $1);}
| args ',' '.'       {$$ = MakeNode(AST_TYPE_DOT, NULL);insert_child($$, $1);}
| '.'                {$$ = MakeNode(AST_TYPE_DOT, NULL);}
| expression         {$$ = $1;}
;

shift_cmd: identificador_accessor TK_OC_SL expression | identificador_accessor TK_OC_SR expression;

return: TK_PR_RETURN expression {$$ = MakeNode(AST_TYPE_RETURN, NULL); insert_child($$, $2);};

conditional_command: 
TK_PR_IF '(' expression ')' TK_PR_THEN command_block
{
  $$ = MakeNode(AST_TYPE_IF_ELSE, NULL);
  insert_child($$, $3);
  insert_child($$, $6);
}
| TK_PR_IF '(' expression ')' TK_PR_THEN command_block TK_PR_ELSE command_block
{
  $$ = MakeNode(AST_TYPE_IF_ELSE, NULL);
  insert_child($$, $3);
  insert_child($$, $6);
  insert_child($$, $8);
}
;

foreach:  TK_PR_FOREACH '(' identificador_accessor ':' expression_list ')' command_block
{
  $$ = MakeNode(AST_TYPE_FOREACH, NULL);
  insert_child($$, $3);
  insert_child($$, $5);
  insert_child($$, $7);
};

for: TK_PR_FOR '(' for_command_list ':' expression ':' for_command_list ')' command_block
{
  $$ = MakeNode(AST_TYPE_FOR, NULL);
  insert_child($$, $3);
  insert_child($$, $5);
  insert_child($$, $7);
  insert_child($$, $9);
};

while_do: TK_PR_WHILE '(' expression ')' TK_PR_DO command_block
{
  $$ = MakeNode(AST_TYPE_WHILE_DO, NULL);
  insert_child($$, $3);
  insert_child($$, $6);
};

do_while: TK_PR_DO  command_block TK_PR_WHILE '(' expression ')'
{
  $$ = MakeNode(AST_TYPE_DO_WHILE, NULL);
  insert_child($$, $2);
  insert_child($$, $5);
};

pipe_command:  
pipe_rec TK_OC_FORWARD_PIPE func_call
{
  $$ = MakeNode(AST_TYPE_FOWARD_PIPE, NULL);
  insert_child($$, $3);
  insert_child($$, $1);
}
| pipe_rec TK_OC_BASH_PIPE func_call
{
  $$ = MakeNode(AST_TYPE_BASH_PIPE, NULL);
  insert_child($$, $3);
  insert_child($$, $1);
};

pipe_rec:  
pipe_rec TK_OC_FORWARD_PIPE func_call
{
  $$ = MakeNode(AST_TYPE_FOWARD_PIPE, NULL);
  insert_child($$, $3);
  insert_child($$, $1);
}
| pipe_rec TK_OC_BASH_PIPE func_call
{
  $$ = MakeNode(AST_TYPE_BASH_PIPE, NULL);
  insert_child($$, $3);
  insert_child($$, $1);
}
| func_call
{
  $$ = $1;
};

switch: TK_PR_SWITCH '(' expression ')' command_block
{
  $$ = MakeNode(AST_TYPE_SWITCH, NULL);
  insert_child($$, $3);
  insert_child($$, $5);
};

expression_list: 
expression_list ',' expression { $$ = $3;insert_child($$, $1); }
| expression                   { $$ = $1; }
;
expression:  
'(' expression ')'        { $$ = $2; }
| identificador_accessor  { $$ = $1; }
| '+' expression          { $$ = $2; }
| '-' expression          { $$ = MakeNode(AST_TYPE_NEGATIVE, NULL); insert_child($$, $2);}
| '!' expression          { $$ = MakeNode(AST_TYPE_NEGATE, NULL); insert_child($$, $2);}
| '&' expression          { $$ = MakeNode(AST_TYPE_ADDRESS, NULL); insert_child($$, $2);}
| '*' expression          { $$ = MakeNode(AST_TYPE_POINTER, NULL); insert_child($$, $2);}
| '?' expression          { $$ = MakeNode(AST_TYPE_QUESTION_MARK, NULL); insert_child($$, $2);}
| '#' expression          { $$ = MakeNode(AST_TYPE_HASHTAG, NULL); insert_child($$, $2);}
| expression '*' expression                 {$$ = MakeNode(AST_TYPE_MUL, NULL);insert_child($$, $1);insert_child($$, $3);}
| expression '/' expression                 {$$ = MakeNode(AST_TYPE_DIV, NULL);insert_child($$, $1);insert_child($$, $3);}
| expression '%' expression                 {$$ = MakeNode(AST_TYPE_REST, NULL);insert_child($$, $1);insert_child($$, $3);}
| expression '+' expression                 {$$ = MakeNode(AST_TYPE_ADD, NULL);insert_child($$, $1);insert_child($$, $3);}
| expression '-' expression                 {$$ = MakeNode(AST_TYPE_SUB, NULL);insert_child($$, $1);insert_child($$, $3);}
| expression '<' expression                 {$$ = MakeNode(AST_TYPE_LS, NULL);insert_child($$, $1);insert_child($$, $3);}
| expression '|' expression                 {$$ = MakeNode(AST_TYPE_BW_OR, NULL);insert_child($$, $1);insert_child($$, $3);}
| expression '&' expression                 {$$ = MakeNode(AST_TYPE_BW_AND, NULL);insert_child($$, $1);insert_child($$, $3);}
| expression '^' expression                 {$$ = MakeNode(AST_TYPE_BW_XOR, NULL);insert_child($$, $1);insert_child($$, $3);}
| expression TK_OC_LE expression            {$$ = MakeNode(AST_TYPE_LE, NULL);insert_child($$, $1);insert_child($$, $3);}
| expression '>' expression                 {$$ = MakeNode(AST_TYPE_GR, NULL);insert_child($$, $1);insert_child($$, $3);}
| expression TK_OC_GE expression            {$$ = MakeNode(AST_TYPE_GE, NULL);insert_child($$, $1);insert_child($$, $3);}
| expression TK_OC_EQ expression            {$$ = MakeNode(AST_TYPE_EQ, NULL);insert_child($$, $1);insert_child($$, $3);}
| expression TK_OC_NE expression            {$$ = MakeNode(AST_TYPE_NE, NULL);insert_child($$, $1);insert_child($$, $3);}
| expression TK_OC_AND expression           {$$ = MakeNode(AST_TYPE_AND, NULL);insert_child($$, $1);insert_child($$, $3);}
| expression TK_OC_OR expression            {$$ = MakeNode(AST_TYPE_OR, NULL);insert_child($$, $1);insert_child($$, $3);}
| expression '?' expression ':' expression  {$$ = MakeNode(AST_TYPE_TERNARY, NULL);insert_child($$, $1);insert_child($$, $3);insert_child($$, $5);}
| pipe_command                              {$$ = $1;}
| func_call                                 {$$ = $1;}
| tk_lit                                    {$$ = $1;}
;

%%

tree_node_t* MakeNode(token_type_t type, valor_lexico_t* valor_lexico) {
  valor_lexico->type = type;
  valor_lexico->line = 0;
  return make_node(valor_lexico);
}