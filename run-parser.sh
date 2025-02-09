bison -d src/parser.y
flex src/lexer.l
gcc parser.tab.c lex.yy.c -o parser -lfl


./parser < programs/program1.esp