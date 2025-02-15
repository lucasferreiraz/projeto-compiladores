#!/usr/bin/env bash

mkdir -p build bin

bison -d src/parser/parser.y -o build/parser.tab.c
flex -o build/lex.yy.c src/lexer/lexer.l

gcc -I src/lib/symbol_table \
    -I src/lib/pin_manager \
    -I src/lib/type_checker \
    -I src/lib/code_generator \
    build/parser.tab.c build/lex.yy.c \
    src/lib/symbol_table/symbol_table.c \
    src/lib/pin_manager/pin_manager.c \
    src/lib/type_checker/type_checker.c \
    src/lib/code_generator/code_generator.c \
    -o bin/parser -lfl