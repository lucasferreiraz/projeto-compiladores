#!/usr/bin/env bash

bison -d src/parser.y
flex src/lexer.l
gcc parser.tab.c lex.yy.c -o parser -lfl


./parser programs/program6.esp