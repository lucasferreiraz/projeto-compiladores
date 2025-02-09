flex src/lexer.l
gcc lex.yy.c -o lexer -lfl

./lexer < programs/program1.esp
