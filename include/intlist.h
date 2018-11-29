#ifndef __INTLIST_H
#define __INTLIST_H

#include <stdio.h>
#include <stdlib.h>


typedef struct intlist {
	int value;
	struct intlist* next;
} intlist_t;

extern intlist_t *_list;
extern int* _reg_rfp_offset;
extern int __save_regs__;

intlist_t* intlist_append(intlist_t* list, int value);
void intlist_free(intlist_t* list);

#endif