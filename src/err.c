#include "err.h"

void quit(int code, char* message) {
    printf("%s\n", message);
    exit(code);
}