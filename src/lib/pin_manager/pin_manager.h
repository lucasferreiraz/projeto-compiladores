#ifndef PIN_MANAGER_H
#define PIN_MANAGER_H

#define MAX_PINS 50

typedef enum {
    PIN_UNDEFINED,
    PIN_INPUT,
    PIN_OUTPUT,
    PIN_PWM
} PinMode;

struct pin_config {
    char* name;
    PinMode mode;
};

extern struct pin_config pin_table[MAX_PINS];
extern int pin_count;
extern int pwm_channel;

void set_pin_mode(char* name, PinMode mode);
PinMode get_pin_mode(char* name);
void check_pin_mode(char* name, PinMode required_mode, const char* operation, int line);

#endif