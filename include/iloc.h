#ifndef __ILOC_H
#define __ILOC_H

#define OP_NOP          0
#define OP_ADD          1
#define OP_SUB          2
#define OP_MULT         3
#define OP_DIV          4
#define OP_ADDI         5
#define OP_SUBI         6
#define OP_RSUBI        7
#define OP_MULTI        8
#define OP_DIVI         9
#define OP_RDIVI        10
#define OP_LSHIFT       11
#define OP_LSHIFTI      12
#define OP_RSHIFT       13
#define OP_RSHIFTI      14
#define OP_AND          15
#define OP_ANDI         16
#define OP_OR           17
#define OP_ORI          18
#define OP_XOR          19
#define OP_XORI         20
#define OP_LOADI        21
#define OP_LOAD         22
#define OP_LOADAI       23
#define OP_LOADA0       24
#define OP_CLOAD        25
#define OP_CLOADAI      26
#define OP_CLOADA0      27
#define OP_STORE        28
#define OP_STOREAI      29
#define OP_STOREA0      30
#define OP_CSTORE       31
#define OP_CSTOREAI     32
#define OP_CSTOREA0     33
#define OP_I2I          34
#define OP_C2C          35
#define OP_C2I          36
#define OP_I2C          37
#define OP_JUMPI        38
#define OP_JUMP         39
#define OP_CBR          40
#define OP_CMP_LT       41
#define OP_CMP_LE       42
#define OP_CMP_EQ       43
#define OP_CMP_GE       44
#define OP_CMP_GT       45
#define OP_CMP_NE       46

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct operation {
  int code;
  char *label;
  int left_ops[2];
  int right_ops[2];
} operation_t;

typedef struct operation_list {
  operation_t *op;
  struct operation_list *next;

} operation_list_t;

int getLabel();
int getRegister();
void print_op_list(operation_list_t *iloc_list);

#endif