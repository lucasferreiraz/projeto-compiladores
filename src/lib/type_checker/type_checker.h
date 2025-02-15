#ifndef TYPE_CHECKER_H
#define TYPE_CHECKER_H

typedef enum {
    TYPE_UNKNOWN,
    TYPE_INT,
    TYPE_BOOL,
    TYPE_STRING
} VarType;

extern char current_type[20];

VarType str_to_type(const char* type);
void check_value_type(const char* var_name, const char* value, VarType expected_type, int line);
void check_operation_type(char* var_name, char operation, int line);
void check_type_compatibility(char* var_name, char* value_type, int line);

#endif