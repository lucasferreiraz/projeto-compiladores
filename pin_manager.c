#include "pin_manager.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

struct pin_config pin_table[MAX_PINS];
int pin_count = 0;
int pwm_channel = 0;

void set_pin_mode(char* name, PinMode mode) {
    for(int i = 0; i < pin_count; i++) {
        if(strcmp(pin_table[i].name, name) == 0) {
            pin_table[i].mode = mode;
            return;
        }
    }
    if(pin_count < MAX_PINS) {
        pin_table[pin_count].name = strdup(name);
        pin_table[pin_count].mode = mode;
        pin_count++;
    }
}

PinMode get_pin_mode(char* name) {
    for(int i = 0; i < pin_count; i++) {
        if(strcmp(pin_table[i].name, name) == 0) {
            return pin_table[i].mode;
        }
    }
    return PIN_UNDEFINED;
}

void check_pin_mode(char* name, PinMode required_mode, const char* operation, int line) {
    PinMode current_mode = get_pin_mode(name);
    if(current_mode == PIN_UNDEFINED) {
        fprintf(stderr, "Erro semântico: Pino '%s' não foi configurado antes de %s (linha %d)\n", 
                name, operation, line);
        exit(1);
    }
    if(current_mode != required_mode) {
        const char* mode_str[] = {"indefinido", "entrada", "saída", "PWM"};
        fprintf(stderr, "Erro semântico: Operação '%s' requer pino configurado como %s, mas '%s' está configurado como %s (linha %d)\n",
                operation, mode_str[required_mode], name, mode_str[current_mode], line);
        exit(1);
    }
}