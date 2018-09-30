#include "utils.h"

int strToBool(char *boolean) {
  if (!strcmp(boolean, "true"))
    return 1;
  else if (!strcmp(boolean, "false"))
    return 0;
  return -1;
}

char* boolToStr(int boolean) {
  char *str = (char*) malloc(sizeof(char)*12);

  if(boolean)
    strcpy(str, "true");
  else
    strcpy(str, "false");

  return str;
}

char* intToStr(int someInt) {
  char *str = (char*) malloc(sizeof(char)*12);
  sprintf(str, "%d", someInt);
  return str;
}

char* floatToStr(float someFloat) {
  char *str = (char*) malloc(sizeof(char)*12);
  sprintf(str, "%f", someFloat);
  return str;
}

char* someChar(char someChar) {
    char *str = (char*) malloc(sizeof(char)*3);
  sprintf(str, "%c", someChar);
  return str;
}

void kill(char *message) {
  printf("%s\n", message);
  exit(1);
}
