%{
#include "parser.tab.h"
#include "utils.h"
int get_line_number(void);
int cur_line = 1;
int comment_start_line;
void print_tkn(char* str);
valor_lexico_t* construct_valor_lexico();
%}

INT                       [0-9]+
FLOAT                     {INT}\.{INT}
SCI_NOT                   {INT}\.{INT}[Ee][+-]?{INT}
STR                       \"([^"^\n]|\\.)*\"
IDENT                     [a-zA-Z_][a-zA-Z0-9_]*
NEW_LINE                  ("\r\n"|"\n")
SINGLE_LINE_COMMENT       \/\/.*
MULTI_LINE_COMMENT_START  \/\*
MULTI_LINE_COMMENT_END    \*\/

%x BLOCK_COMMENT
%s CODE

%option noyywrap

%%
" "|"\t"
{NEW_LINE}        ++cur_line;
"int"             return TK_PR_INT;
"float"           return TK_PR_FLOAT;
"bool"            return TK_PR_BOOL;
"char"            return TK_PR_CHAR;
"string"          return TK_PR_STRING;
"if"              return TK_PR_IF;
"then"            return TK_PR_THEN;
"else"            return TK_PR_ELSE;
"while"           return TK_PR_WHILE;
"do"              return TK_PR_DO;
"input"           return TK_PR_INPUT;
"output"          return TK_PR_OUTPUT;
"return"          return TK_PR_RETURN;
"const"           return TK_PR_CONST;
"static"          return TK_PR_STATIC;
"foreach"         return TK_PR_FOREACH;
"for"             return TK_PR_FOR;
"switch"          return TK_PR_SWITCH;
"case"            return TK_PR_CASE;
"break"           return TK_PR_BREAK;
"continue"        return TK_PR_CONTINUE;
"class"           return TK_PR_CLASS;
"private"         return TK_PR_PRIVATE;
"public"          return TK_PR_PUBLIC;
"protected"       return TK_PR_PROTECTED;

[\,\;\:\(\)\[\]\{\}\+\-\|\?\*\/\<\>\=\!\&\%\#\^\.\$]    return yytext[0];

"<="              return TK_OC_LE;
">="              return TK_OC_GE;
"=="              return TK_OC_EQ;
"!="              return TK_OC_NE;
"&&"              return TK_OC_AND;
"||"              return TK_OC_OR;
"<<"              return TK_OC_SL;
">>"              return TK_OC_SR;
"%>%"             return TK_OC_FORWARD_PIPE;
"%|%"             return TK_OC_BASH_PIPE;

{INT}             { yylval.valor_lexico = (valor_lexico_t*)construct_valor_lexico(cur_line, LITERAL_INT,    strdup(yytext));return TK_LIT_INT;    }
{FLOAT}|{SCI_NOT} { yylval.valor_lexico = (valor_lexico_t*)construct_valor_lexico(cur_line, LITERAL_FLOAT,  strdup(yytext));return TK_LIT_FLOAT;  }
"false"           { yylval.valor_lexico = (valor_lexico_t*)construct_valor_lexico(cur_line, LITERAL_BOOL,   strdup(yytext));return TK_LIT_FALSE;  }
"true"            { yylval.valor_lexico = (valor_lexico_t*)construct_valor_lexico(cur_line, LITERAL_BOOL,   strdup(yytext));return TK_LIT_TRUE;   }
'.'               { yylval.valor_lexico = (valor_lexico_t*)construct_valor_lexico(cur_line, LITERAL_CHAR,   strdup(yytext));return TK_LIT_CHAR;   }
{STR}             { yylval.valor_lexico = (valor_lexico_t*)construct_valor_lexico(cur_line, LITERAL_STRING, strdup(yytext));return TK_LIT_STRING; }

{SINGLE_LINE_COMMENT}       {}
{MULTI_LINE_COMMENT_START}  { BEGIN(BLOCK_COMMENT); comment_start_line = cur_line; }
<BLOCK_COMMENT>{
    <<EOF>>      { BEGIN(CODE); cur_line = comment_start_line; return TOKEN_ERRO; }
    {NEW_LINE}   ++cur_line;
    \*           { /* flex always matches the string with more text, therefore this will not interfere with the \*\/ match */ }
    \*\/         BEGIN(CODE);
    [^\*\n]*     {/* stops matching when finds either a \n or a * character */}
}

{IDENT}           { yylval.valor_lexico = (valor_lexico_t*)construct_valor_lexico(cur_line, IDENTIFICADOR, strdup(yytext));return TK_IDENTIFICADOR; }
.                 return TOKEN_ERRO;

%%

int get_line_number(void) {
  return cur_line;
}

void yyerror (char const *error) {
   fprintf (stderr, "Line %d: %s\n", get_line_number(), error);
}

valor_lexico_t* construct_valor_lexico(int i, token_type_t type, char* value) {
  valor_lexico_t* vl = (valor_lexico_t*)malloc(sizeof(valor_lexico_t));
  vl->line = i;
  vl->type = type;

  switch(type) {
    case LITERAL_INT: vl->value.intValue = atoi(value);
      break;
    case LITERAL_FLOAT: vl->value.floatValue = atof(value);
      break;
    case LITERAL_BOOL: vl->value.boolValue = strToBool(value);
      break;
    case LITERAL_CHAR: vl->value.charValue = value[1];
      break;
    case IDENTIFICADOR:
    case LITERAL_STRING: vl->value.stringValue = value;
      break;
    default: yyerror("Could find the given type.");
  }

  return vl;
}