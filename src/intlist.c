#include "intlist.h"

intlist_t *_list;
int* _reg_rfp_offset;
int __save_regs__;

intlist_t* intlist_append(intlist_t* list, int value){
	intlist_t* aux=list;
	if(list == NULL){
		list = (intlist_t*) malloc(sizeof(intlist_t));
		list->next = NULL;
		list->value = value;
	}
	else{
		while(aux->next != NULL) aux = aux->next;
		aux->next = (intlist_t*) malloc(sizeof(intlist_t));
		aux = aux->next;
		aux->next = NULL;
		aux->value = value;
	}
	return list;
}

void intlist_free(intlist_t* list){
	intlist_t* aux=list;
	while(list != NULL){aux = list; list = list->next; free(aux);}
}