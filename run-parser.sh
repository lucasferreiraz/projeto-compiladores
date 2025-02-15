#!/usr/bin/env bash

bison -d src/parser.y
flex src/lexer.l
gcc parser.tab.c lex.yy.c symbol_table.c pin_manager.c type_checker.c code_generator.c -o parser -lfl


./parser programs/program4.esp