#include "code_generator.h"
#include <string.h>
#include <stdlib.h>

FILE* output;
char output_filename[256];

void generate_header() {
    fprintf(output, "#include <Arduino.h>\n");
    fprintf(output, "#include <WiFi.h>\n\n");
}

void start_setup() {
    fprintf(output, "\nvoid setup() {\n");
    fprintf(output, "    Serial.begin(115200);\n");
}

void start_loop() {
    fprintf(output, "void loop() {\n");
}

void end_block() {
    fprintf(output, "}\n\n");
}

void generate_output_filename(const char* input_filename) {
    char temp[256];
    strcpy(temp, input_filename);
    
    char* dot = strrchr(temp, '.');
    if (dot != NULL) {
        *dot = '\0';
    }
    
    strcat(temp, ".cpp");
    
    strcpy(output_filename, temp);
}