#ifndef __UTILS_H
#define __UTILS_H

#include <string.h>
#include <stdlib.h>
#include <stdio.h>

int strToBool(char *boolean);
char* boolToStr(int boolean);
void kill(char* message);
#endif