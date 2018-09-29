%code requires {
  #include "valor_lexico.h"
  #include "stdio.h"
  #include "tree.h"
}

%{
  int yylex(void);
  void yyerror (char const *s);
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
%type <node> tk_numeric_lit
%type <node> tk_lit
%type <node> tk_id_or_lit
%type <node> std_type
%type <node> protection
%type <node> identificador_accessor
%type <node> command_seq
%type <node> simple_command
%type <node> all_command
%type <node> command_in_for
%type <node> command_not_in_for
%type <node> attribution
%type <node> input
%type <node> output
%type <node> return
%type <node> conditional_command
%type <node> foreach
%type <node> for
%type <node> do_while
%type <node> while_do
%type <node> switch


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

programa: programa_rec;
programa_rec: programa_rec new_type_decl
            | programa_rec global_var_decl 
            | programa_rec func 
            | %empty;

std_type: TK_PR_INT { $$ = make_node($1); } | TK_PR_FLOAT { $$ = make_node($1); } | TK_PR_BOOL { $$ = make_node($1); } | TK_PR_CHAR { $$ = make_node($1); } | TK_PR_STRING { $$ = make_node($1); };
protection: TK_PR_PRIVATE { $$ = make_node($1); } | TK_PR_PUBLIC { $$ = make_node($1); } | TK_PR_PROTECTED { $$ = make_node($1); };
tk_numeric_lit: TK_LIT_INT { $$ = make_node($1); } 
              | TK_LIT_FLOAT { $$ = make_node($1); };

tk_lit: tk_numeric_lit { $$ = $1; } | TK_LIT_FALSE { $$ = make_node($1); } | TK_LIT_TRUE { $$ = make_node($1); } | TK_LIT_CHAR { $$ = make_node($1); } | TK_LIT_STRING { $$ = make_node($1); }
tk_id_or_lit: tk_lit { $$ = $1; } | TK_IDENTIFICADOR { $$ = make_node($1); } ;

identificador_accessor:  TK_IDENTIFICADOR { $$ = make_node($1); }
                       | TK_IDENTIFICADOR '$' TK_IDENTIFICADOR
                       | TK_IDENTIFICADOR '[' expression ']'
                       | TK_IDENTIFICADOR '[' expression ']' '$' TK_IDENTIFICADOR
;

new_type_decl: TK_PR_CLASS TK_IDENTIFICADOR '[' field_list ']' ';';
field_list: field_list ':' field | field;
field: protection std_type TK_IDENTIFICADOR | std_type TK_IDENTIFICADOR;

global_var_decl: TK_IDENTIFICADOR gv_type ';' | TK_IDENTIFICADOR '[' TK_LIT_INT ']' gv_type';';
gv_type: TK_PR_STATIC std_type | std_type | TK_PR_STATIC TK_IDENTIFICADOR | TK_IDENTIFICADOR;

func: func_head func_body;

func_head:  std_type TK_IDENTIFICADOR param_list 
          | TK_PR_STATIC std_type TK_IDENTIFICADOR param_list
          | TK_IDENTIFICADOR TK_IDENTIFICADOR param_list
          | TK_PR_STATIC TK_IDENTIFICADOR TK_IDENTIFICADOR param_list
;

param_list: '(' parameters ')' | '(' ')';
parameters: parameters ',' param | param;
param:  std_type TK_IDENTIFICADOR 
      | TK_PR_CONST std_type TK_IDENTIFICADOR
      | TK_IDENTIFICADOR TK_IDENTIFICADOR
      | TK_PR_CONST TK_IDENTIFICADOR TK_IDENTIFICADOR
;

func_body: command_block;

command_block: '{' command_seq '}' | '{' '}';

command_seq: command_seq simple_command | simple_command | command_seq TK_PR_CASE TK_LIT_INT ':' | TK_PR_CASE TK_LIT_INT ':';

for_command_list: for_command_list ',' command_in_for | command_in_for;

simple_command: all_command ';' { $$ = $1; };

all_command: command_in_for { $$ = $1; } | command_not_in_for { $$ = $1; };

command_in_for:     command_block
                  | local_var_decl
                  | attribution { $$ = $1; }
                  | input { $$ = $1; }
                  | shift_cmd
                  | return { $$ = $1; }
                  | TK_PR_BREAK { $$ = make_node($1); }
                  | TK_PR_CONTINUE { $$ = make_node($1); }
                  | conditional_command { $$ = $1; }
                  | foreach { $$ = $1; }
                  | while_do { $$ = $1; }
                  | do_while { $$ = $1; }
                  | pipe_command
;

command_not_in_for:  output { $$ = $1; }
                   | switch { $$ = $1; }
                   | func_call
                   | for { $$ = $1; }
;

local_var_decl: TK_PR_STATIC local_var_static_consumed | local_var_static_consumed;
local_var_static_consumed: TK_PR_CONST local_var_const_consumed | local_var_const_consumed;
local_var_const_consumed:  std_type TK_IDENTIFICADOR
                         | TK_IDENTIFICADOR TK_IDENTIFICADOR
                         | std_type TK_IDENTIFICADOR TK_OC_LE tk_id_or_lit
;

attribution: identificador_accessor '=' expression { $$ = make_node($2); insert_child($$, $1); insert_child($$, $3); };

input: TK_PR_INPUT expression { $$ = make_node($1); insert_child($$, $2); };
output: TK_PR_OUTPUT expression_list { $$ = make_node($1); insert_child($$, $2); };

func_call: TK_IDENTIFICADOR '(' args ')' | TK_IDENTIFICADOR '(' ')';
args: args ',' expression | args ',' '.' | '.' | expression;

shift_cmd: identificador_accessor TK_OC_SL expression | identificador_accessor TK_OC_SR expression;

return: TK_PR_RETURN expression { $$ = make_node($1); insert_child($$, $2); };

conditional_command: TK_PR_IF '(' expression ')' TK_PR_THEN command_block { $$ = make_node($1); insert_child($$, $3); insert_child($$, $6);  }
                   | TK_PR_IF '(' expression ')' TK_PR_THEN command_block TK_PR_ELSE command_block { $$ = make_node($1); insert_child($$, $3); insert_child($$, $6); insert_child($$, $8); }
;

foreach:  TK_PR_FOREACH '(' identificador_accessor ':' expression_list ')' command_block { $$ = make_node($1); insert_child($$, $3); insert_child($$, $5); insert_child($$, $7); };
for:      TK_PR_FOR '(' for_command_list ':' expression ':' for_command_list ')' command_block { $$ = make_node($1); insert_child($$, $3); insert_child($$, $5); insert_child($$, $7); insert_child($$, $9); };
while_do: TK_PR_WHILE '(' expression ')' TK_PR_DO command_block { $$ = make_node($1); insert_child($$, $3); insert_child($$, $6); };
do_while: TK_PR_DO command_block TK_PR_WHILE '(' expression ')' { $$ = make_node($1);  insert_child($$, $2);  insert_child($$, $5); };

pipe_command:  pipe_rec TK_OC_FORWARD_PIPE func_call
             | pipe_rec TK_OC_BASH_PIPE func_call
;

pipe_rec:  pipe_rec TK_OC_FORWARD_PIPE func_call
         | pipe_rec TK_OC_BASH_PIPE func_call
         | func_call
;

switch: TK_PR_SWITCH '(' expression ')' command_block { $$ = make_node($1); insert_child($$, $3); insert_child($$, $5); };

expression_list: expression_list ',' expression | expression;
expression:  '(' expression ')'
           | identificador_accessor
           | '+' expression
           | '-' expression
           | '!' expression
           | '&' expression
           | '*' expression
           | '?' expression
           | '#' expression
           | expression '*' expression
           | expression '/' expression
           | expression '%' expression
           | expression '+' expression
           | expression '-' expression
           | expression '<' expression
           | expression '|' expression
           | expression '&' expression
           | expression '^' expression
           | expression TK_OC_LE expression
           | expression '>' expression
           | expression TK_OC_GE expression
           | expression TK_OC_EQ expression
           | expression TK_OC_NE expression
           | expression TK_OC_AND expression
           | expression TK_OC_OR expression
           | expression '?' expression ':' expression
           | pipe_command
           | func_call
           | tk_lit
;

%%