#include "utils.h"

int strToBool(char *boolean) {
  if (!strcmp(boolean, "true"))
    return 1;
  else if (!strcmp(boolean, "false"))
    return 0;
  return -1;
}