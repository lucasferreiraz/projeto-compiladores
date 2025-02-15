#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#define MAX_SYMBOLS 100

struct symbol {
    char* name;
    char* type;
};

extern struct symbol symbol_table[MAX_SYMBOLS];
extern int symbol_count;

void add_symbol(char* name, char* type, int line);
int lookup_symbol(char* name);
void check_variable(char* name, int line);
char* get_variable_type(char* name);

#endif