// symbol_table.c
#include "symbol_table.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

struct symbol symbol_table[MAX_SYMBOLS];
int symbol_count = 0;

void add_symbol(char* name, char* type, int line) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].name, name) == 0 && 
            strcmp(symbol_table[i].type, type) == 0) {
            fprintf(stderr, "Erro semântico: Variável '%s' do tipo '%s' já foi declarada (linha %d)\n", 
                    name, type, line);
            exit(1);
        }
    }
    
    if (symbol_count < MAX_SYMBOLS) {
        symbol_table[symbol_count].name = strdup(name);
        symbol_table[symbol_count].type = strdup(type);
        symbol_count++;
    }
}

int lookup_symbol(char* name) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].name, name) == 0) {
            return i;
        }
    }
    return -1;
}

void check_variable(char* name, int line) {
    if (lookup_symbol(name) == -1) {
        fprintf(stderr, "Erro semântico: Variável '%s' não foi declarada (linha %d)\n", name, line);
        exit(1);
    }
}

char* get_variable_type(char* name) {
    int index = lookup_symbol(name);
    if (index != -1) {
        return symbol_table[index].type;
    }
    return NULL;
}