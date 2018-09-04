%{
int yylex(void);
void yyerror (char const *s);
%}

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

//The first precedence/associativity declaration in the file declares the operators whose precedence is lowest
//the next such declaration declares the operators whose precedence is a little higher, and so on.
// Created this following standard C precendence
%left TK_OC_OR
%left TK_OC_AND
%left TK_OC_EQ TK_OC_NE 
%left '<' TK_OC_LE '>' TK_OC_GE
%left '+' '-'
%left '*' '/' '%'

//TODO: Should this be max prio ?
%left TK_OC_FORWARD_PIPE TK_OC_BASH_PIPE

//TODO: Is case a command ? wtf

%%

programa: programa start | start;
start: new_type_decl | galobal_var_decl | func;

std_type: TK_PR_INT | TK_PR_FLOAT | TK_PR_BOOL | TK_PR_CHAR | TK_PR_STRING;
protection: TK_PR_PRIVATE | TK_PR_PUBLIC | TK_PR_PROTECTED;
tk_numeric_lit: TK_LIT_INT | TK_LIT_FLOAT;
tk_lit: tk_numeric_lit | TK_LIT_FALSE | TK_LIT_TRUE | TK_LIT_CHAR | TK_LIT_STRING;
tk_id_or_lit: tk_lit | TK_IDENTIFICADOR;

identificador_accessor:  TK_IDENTIFICADOR
                       | TK_IDENTIFICADOR '$' TK_IDENTIFICADOR 
                       | TK_IDENTIFICADOR '[' expression ']'
                       | TK_IDENTIFICADOR '[' expression ']' '$' TK_IDENTIFICADOR
;

new_type_decl: TK_PR_CLASS TK_IDENTIFICADOR '{' field_list '}' ';';
field_list: field_list ':' field | field;
field: protection std_type TK_IDENTIFICADOR | std_type TK_IDENTIFICADOR;

galobal_var_decl: TK_IDENTIFICADOR gv_type ';' | TK_IDENTIFICADOR '[' TK_LIT_INT ']' ';';
gv_type: TK_PR_STATIC std_type | std_type;

func: func_head func_body;

func_head: std_type TK_IDENTIFICADOR param_list | TK_PR_STATIC std_type TK_IDENTIFICADOR param_list;
param_list: '(' parameters ')' | '(' ')';
parameters: parameters ',' param | param;
param: std_type TK_IDENTIFICADOR | TK_PR_CONST std_type TK_IDENTIFICADOR;

func_body: command_block;

command_block: '{' command_seq '}' | '{' '}';
command_seq: command_seq simple_command ';' | simple_command ';';

simple_command:  local_var_decl 
               | attribution 
               | input 
               | output 
               | func_call 
               | shift_cmd 
               | return
               | TK_PR_BREAK
               | TK_PR_CONTINUE
;

local_var_decl: TK_IDENTIFICADOR lv_type | TK_IDENTIFICADOR lv_type TK_OC_LE tk_id_or_lit;
lv_type: TK_PR_STATIC TK_PR_CONST std_type | TK_PR_STATIC std_type | std_type;

attribution: identificador_accessor '=' expression;

input: TK_PR_INPUT expression;
output: TK_PR_OUTPUT expression_list;

func_call: TK_IDENTIFICADOR '(' args ')';
args: args ',' expression | args ',' '.' | '.' | expression;

shift_cmd: identificador_accessor TK_OC_SL expression | identificador_accessor TK_OC_SR expression;

return: TK_PR_RETURN expression;

expression_list: expression_list ',' expression | expression;
expression:  '(' expression ')'
           | identificador_accessor
           | expression TK_OC_FORWARD_PIPE expression
           | expression TK_OC_BASH_PIPE expression
           | expression '*' expression
           | expression '/' expression
           | expression '%' expression
           | expression '+' expression
           | expression '-' expression
           | expression '<' expression
           | expression TK_OC_LE expression
           | expression '>' expression
           | expression TK_OC_GE expression
           | expression TK_OC_EQ expression
           | expression TK_OC_NE expression
           | expression TK_OC_AND expression
           | expression TK_OC_OR expression
           | func_call
           | tk_lit
;

%%