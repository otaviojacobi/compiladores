#include "utils.h"

int strToBool(char *boolean) {
  if (!strcmp(boolean, "true"))
    return 1;
  else if (!strcmp(boolean, "false"))
    return 0;
  return -1;
}

char* boolToStr(int boolean) {
  char *str = (char*) malloc(sizeof(char)*sizeof("false"));

  if(boolean)
    strcpy(str, "true");
  else
    strcpy(str, "false");

  return str;
}

void kill(char *message) {
  printf("%s\n", message);
  exit(1);
}