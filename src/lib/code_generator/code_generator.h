#ifndef CODE_GENERATOR_H
#define CODE_GENERATOR_H

#include <stdio.h>

extern FILE* output;
extern char output_filename[256];

void generate_header();
void start_setup();
void start_loop();
void end_block();
void generate_output_filename(const char* input_filename);

#endif