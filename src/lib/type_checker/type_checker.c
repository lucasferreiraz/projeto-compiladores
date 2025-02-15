#include "type_checker.h"
#include "symbol_table.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

char current_type[20];

VarType str_to_type(const char* type) {
    if (strcmp(type, "inteiro") == 0) return TYPE_INT;
    if (strcmp(type, "booleano") == 0) return TYPE_BOOL;
    if (strcmp(type, "texto") == 0) return TYPE_STRING;
    return TYPE_UNKNOWN;
}

void check_value_type(const char* var_name, const char* value, VarType expected_type, int line) {
    char str_value[20];
    if (value[0] >= '0' && value[0] <= '9') {
        sprintf(str_value, "%d", atoi(value));
        value = str_value;
    }
    
    if (value[0] >= '0' && value[0] <= '9') {
        if (expected_type == TYPE_STRING) {
            fprintf(stderr, "Erro semântico: Valor numérico não pode ser atribuído a variável texto '%s' (linha %d)\n", 
                    var_name, line);
            exit(1);
        }
    } else if (value[0] == '"') {
        if (expected_type != TYPE_STRING) {
            fprintf(stderr, "Erro semântico: String não pode ser atribuída a variável %s '%s' (linha %d)\n", 
                    expected_type == TYPE_INT ? "inteiro" : "booleano", var_name, line);
            exit(1);
        }
    }
}

void check_operation_type(char* var_name, char operation, int line) {
    char* type = get_variable_type(var_name);
    VarType var_type = str_to_type(type);
    
    switch(var_type) {
        case TYPE_STRING:
            fprintf(stderr, "Erro semântico: Operações aritméticas não são permitidas com texto (linha %d)\n", line);
            exit(1);
            break;
        case TYPE_BOOL:
            if (operation != '=' && operation != '!' && operation != '&' && operation != '|') {
                fprintf(stderr, "Erro semântico: Operação aritmética não permitida com booleano (linha %d)\n", line);
                exit(1);
            }
            break;
        default:
            break;
    }
}

void check_type_compatibility(char* var_name, char* value_type, int line) {
    char* var_type = get_variable_type(var_name);
    if (strcmp(var_type, value_type) != 0) {
        fprintf(stderr, "Erro semântico: Tipo incompatível. Variável '%s' é do tipo '%s' mas recebeu valor do tipo '%s' (linha %d)\n",
                var_name, var_type, value_type, line);
        exit(1);
    }
}