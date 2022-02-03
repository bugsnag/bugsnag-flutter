#include <stddef.h>

typedef struct {
    int value;
} dummy;

__attribute__((visibility("default"))) __attribute__((used))
void null_dereference(void) {
    dummy *badPtr = NULL;
    badPtr->value = 10;
}
