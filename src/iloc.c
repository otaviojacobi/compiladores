#include "iloc.h"

int current_label = 0;
int current_register = 0;

int getLabel() {
  return ++current_label;
}

int getRegister() {
  return ++current_register;
}

void print_op(operation_t *op) {

  switch(op->code) {
    case OP_NOP:
      break;
    case OP_ADD:
      printf("add r%d, r%d => r%d\n", (op->left_ops)[0], (op->left_ops)[1], (op->right_ops)[0]);
      break;
    case OP_SUB:
      printf("sub r%d, r%d => r%d\n", (op->left_ops)[0], (op->left_ops)[1], (op->right_ops)[0]);
      break;
    case OP_MULT:
      printf("mult r%d, r%d => r%d\n", (op->left_ops)[0], (op->left_ops)[1], (op->right_ops)[0]);
      break;
    case OP_DIV:
      printf("div r%d, r%d => r%d\n", (op->left_ops)[0], (op->left_ops)[1], (op->right_ops)[0]);
      break;
    case OP_ADDI:
      printf("addI r%d, %d => r%d\n", (op->left_ops)[0], (op->left_ops)[1], (op->right_ops)[0]);
      break;
    case OP_SUBI:
      printf("subI r%d, %d => r%d\n", (op->left_ops)[0], (op->left_ops)[1], (op->right_ops)[0]);
      break;
    case OP_RSUBI:
      printf("rsubI r%d, %d => r%d\n", (op->left_ops)[0], (op->left_ops)[1], (op->right_ops)[0]);
      break;
    case OP_MULTI:
      printf("multI r%d, %d => r%d\n", (op->left_ops)[0], (op->left_ops)[1], (op->right_ops)[0]);
      break;
    case OP_DIVI:
      printf("divI r%d, %d => r%d\n", (op->left_ops)[0], (op->left_ops)[1], (op->right_ops)[0]);
      break;
    case OP_RDIVI:
      printf("rdivI r%d, %d => r%d\n", (op->left_ops)[0], (op->left_ops)[1], (op->right_ops)[0]);
      break;
    case OP_LSHIFT:
      printf("lshift r%d, r%d => r%d\n", (op->left_ops)[0], (op->left_ops)[1], (op->right_ops)[0]);
      break;
    case OP_LSHIFTI:
      printf("lshiftI r%d, %d => r%d\n", (op->left_ops)[0], (op->left_ops)[1], (op->right_ops)[0]);
      break;
    case OP_RSHIFT:
      printf("rshift r%d, r%d => r%d\n", (op->left_ops)[0], (op->left_ops)[1], (op->right_ops)[0]);
      break;
    case OP_RSHIFTI:
      printf("rshiftI r%d, %d => r%d\n", (op->left_ops)[0], (op->left_ops)[1], (op->right_ops)[0]);
      break;
    case OP_AND:
      printf("and r%d, r%d => r%d\n", (op->left_ops)[0], (op->left_ops)[1], (op->right_ops)[0]);
      break;
    case OP_ANDI:
      printf("andI r%d, %d => r%d\n", (op->left_ops)[0], (op->left_ops)[1], (op->right_ops)[0]);
      break;
    case OP_OR:
      printf("or r%d, r%d => r%d\n", (op->left_ops)[0], (op->left_ops)[1], (op->right_ops)[0]);
      break;
    case OP_ORI:
      printf("orI r%d, %d => r%d\n", (op->left_ops)[0], (op->left_ops)[1], (op->right_ops)[0]);
      break;
    case OP_XOR:
      printf("xor r%d, r%d => r%d\n", (op->left_ops)[0], (op->left_ops)[1], (op->right_ops)[0]);
      break;
    case OP_XORI:
      printf("xorI r%d, %d => r%d\n", (op->left_ops)[0], (op->left_ops)[1], (op->right_ops)[0]);
      break;
    case OP_LOADI:
      printf("loadI %d => r%d\n", (op->left_ops)[0], (op->right_ops)[0]);
      break;
    case OP_LOAD:
      printf("load r%d => r%d\n", (op->left_ops)[0], (op->right_ops)[0]);
      break;
    case OP_LOADAI:
      if((op->left_ops)[0] == -1)
        printf("loadAI rfp, %d => r%d\n", (op->left_ops)[1], (op->right_ops)[0]);
      else if((op->left_ops)[0] == -2)
        printf("loadAI rbss, %d => r%d\n", (op->left_ops)[1], (op->right_ops)[0]);
      else
        printf("loadAI r%d, %d => r%d\n", (op->left_ops)[0], (op->left_ops)[1], (op->right_ops)[0]);
      break;
    case OP_LOADA0:
      printf("loadA0 r%d, r%d => r%d\n", (op->left_ops)[0], (op->left_ops)[1], (op->right_ops)[0]);
      break;
    case OP_CLOAD:
      printf("cload r%d => r%d\n", (op->left_ops)[0], (op->right_ops)[0]);
      break;
    case OP_CLOADAI:
      printf("cloadAI r%d, %d => r%d\n", (op->left_ops)[0], (op->left_ops)[1], (op->right_ops)[0]);
      break;
    case OP_CLOADA0:
      printf("cloadA0 r%d, r%d => r%d\n", (op->left_ops)[0], (op->left_ops)[1], (op->right_ops)[0]);  
      break;
    case OP_STORE:
      printf("store r%d => r%d\n", (op->left_ops)[0], (op->right_ops)[0]);
      break;
    case OP_STOREAI:
      if((op->right_ops)[0] == -1)
        printf("storeAI r%d => rfp, %d\n", (op->left_ops)[0], (op->right_ops)[1]);
      else if((op->right_ops)[0] == -2)
        printf("storeAI r%d => rbss, %d\n", (op->left_ops)[0], (op->right_ops)[1]); 
      else
        printf("storeAI r%d => r%d, %d\n", (op->left_ops)[0], (op->right_ops)[0], (op->right_ops)[1]);
      break;
    case OP_STOREA0:
      printf("storeA0 r%d => r%d, r%d\n", (op->left_ops)[0], (op->right_ops)[0], (op->right_ops)[1]);
      break;
    case OP_CSTORE:
      printf("cstore r%d => r%d\n", (op->left_ops)[0], (op->right_ops)[0]);
      break;
    case OP_CSTOREAI:
      printf("cstoreAI r%d => r%d, %d\n", (op->left_ops)[0], (op->right_ops)[0], (op->right_ops)[1]);
      break;
    case OP_CSTOREA0:
      printf("cstoreA0 r%d => r%d, r%d\n", (op->left_ops)[0], (op->right_ops)[0], (op->right_ops)[1]);
      break;
    case OP_I2I:
      printf("i2i r%d => r%d\n", (op->left_ops)[0], (op->right_ops)[0]);
      break;
    case OP_C2C:
      printf("c2c r%d => r%d\n", (op->left_ops)[0], (op->right_ops)[0]);
      break;
    case OP_C2I:
      printf("c2i r%d => r%d\n", (op->left_ops)[0], (op->right_ops)[0]);
      break;
    case OP_I2C:
      printf("i2c r%d => r%d\n", (op->left_ops)[0], (op->right_ops)[0]);
      break;
    case OP_JUMPI:
      printf("jumpI -> L%d\n", (op->right_ops)[0]);
      break;
    case OP_JUMP:
      printf("jump -> r%d\n", (op->right_ops)[0]);
      break;
    case OP_CBR:
      printf("cbr r%d -> L%d, L%d\n", (op->left_ops)[0], (op->right_ops)[0], (op->right_ops)[1]);
      break;
    case OP_CMP_LT:
      printf("cmp_LT r%d, r%d => r%d\n", (op->left_ops)[0], (op->left_ops)[1], (op->right_ops)[0]);
      break;
    case OP_CMP_LE:
      printf("cmp_LE r%d, r%d => r%d\n", (op->left_ops)[0], (op->left_ops)[1], (op->right_ops)[0]);
      break;
    case OP_CMP_EQ:
      printf("cmp_EQ r%d, r%d => r%d\n", (op->left_ops)[0], (op->left_ops)[1], (op->right_ops)[0]);
      break;
    case OP_CMP_GE:
      printf("cmp_GE r%d, r%d => r%d\n", (op->left_ops)[0], (op->left_ops)[1], (op->right_ops)[0]);  
      break;
    case OP_CMP_GT:
      printf("cmp_GT r%d, r%d => r%d\n", (op->left_ops)[0], (op->left_ops)[1], (op->right_ops)[0]);  
      break;
    case OP_CMP_NE:
      printf("cmp_NE r%d, r%d => r%d\n", (op->left_ops)[0], (op->left_ops)[1], (op->right_ops)[0]);  
      break;
    case LABEL:
      printf("L%d: \n", op->label);
  }
}

void print_op_list(operation_list_t *iloc_list) {

  while(iloc_list != NULL) {
    print_op(iloc_list->op);
    iloc_list = iloc_list->next;
  }
}

operation_list_t* create_operation_list_node(int code, int label) {
  operation_list_t* op_list = (operation_list_t*)malloc(sizeof(operation_list_t));
  operation_t* op = (operation_t*)malloc(sizeof(operation_t));
  op->code = code;
  op->label = label;
  op_list->op = op;
  op_list->next = NULL;
  return op_list;
}

int getOpFromType(int type) {
  switch(type) {
    case AST_TYPE_ADD: return OP_ADD;
    case AST_TYPE_MUL: return OP_MULT;
    case AST_TYPE_DIV: return OP_DIV;
    case AST_TYPE_SUB: return OP_SUB;
    case AST_TYPE_LS: return OP_CMP_LT;
    case AST_TYPE_LE: return OP_CMP_LE;
    case AST_TYPE_GR: return OP_CMP_GT;
    case AST_TYPE_GE: return OP_CMP_GE;
    case AST_TYPE_EQ: return OP_CMP_EQ;
    case AST_TYPE_NE: return OP_CMP_NE;
    case AST_TYPE_NEGATIVE: return OP_SUB;

  }
}