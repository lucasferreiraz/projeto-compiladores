%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex(void);
%}

%option noyywrap
%option yylineno

%%

[ \t\r]+                 
\n                       { return '\n'; }

"config"                 { printf("TOKEN: CONFIG\n"); }
"repita"                 { printf("TOKEN: REPITA\n"); }
"fim"                    { printf("TOKEN: FIM\n"); }
"inteiro"                { printf("TOKEN: INTEIRO\n"); }
"booleano"               { printf("TOKEN: BOOLEANO\n"); }
"texto"                  { printf("TOKEN: TEXTO\n"); }
"var"                    { printf("TOKEN: VAR\n"); }
"se"                     { printf("TOKEN: SE\n"); }
"senao"                  { printf("TOKEN: SENAO\n"); }
"entao"                  { printf("TOKEN: ENTAO\n"); }
"e"                      { printf("TOKEN: E_LOGICO\n"); }
"ou"                     { printf("TOKEN: OU_LOGICO\n"); }
"enquanto"               { printf("TOKEN: ENQUANTO\n"); }
"configurar"             { printf("TOKEN: CONFIGURAR\n"); }
"como"                   { printf("TOKEN: COMO\n"); }
"com"                    { printf("TOKEN: COM\n"); }
"saida"                  { printf("TOKEN: SAIDA\n"); }
"entrada"                { printf("TOKEN: ENTRADA\n"); }
"ligar"                  { printf("TOKEN: LIGAR\n"); }
"desligar"               { printf("TOKEN: DESLIGAR\n"); }
"canal"                  { printf("TOKEN: CANAL\n"); }
"ajustarPWM"             { printf("TOKEN: AJUSTAR_PWM\n"); }
"esperar"                { printf("TOKEN: ESPERAR\n"); }
"lerDigital"             { printf("TOKEN: LER_DIGITAL\n"); }
"lerAnalogico"           { printf("TOKEN: LER_ANALOGICO\n"); }
"conectarWifi"           { printf("TOKEN: CONECTAR_WIFI\n"); }
"enviarHttp"             { printf("TOKEN: ENVIAR_HTTP\n"); }
"configurarSerial"       { printf("TOKEN: CONFIGURAR_SERIAL\n"); }
"escreverSerial"         { printf("TOKEN: ESCREVER_SERIAL\n"); }
"lerSerial"              { printf("TOKEN: LER_SERIAL\n"); }

"//".*                   {  }
[0-9]+                   { printf("TOKEN: NUMERO [%s]\n", yytext); }
\"[^\"]*\"               { printf("TOKEN: STRING [%s]\n", yytext); }
[a-zA-Z_][a-zA-Z0-9_]*   { printf("TOKEN: IDENTIFICADOR [%s]\n", yytext); }

"=="                     { printf("TOKEN: IGUAL\n"); }
"!="                     { printf("TOKEN: DIFERENTE\n"); }
"<"                      { printf("TOKEN: MENOR\n"); }
">"                      { printf("TOKEN: MAIOR\n"); }
"<="                     { printf("TOKEN: MENOR_IGUAL\n"); }
">="                     { printf("TOKEN: MAIOR_IGUAL\n"); }
"="                      { printf("TOKEN: ATRIBUICAO\n"); }
"+"                      { printf("TOKEN: MAIS\n"); }
"-"                      { printf("TOKEN: MENOS\n"); }
"*"                      { printf("TOKEN: MULT\n"); }
"/"                      { printf("TOKEN: DIV\n"); }
";"                      { printf("TOKEN: PONTO_VIRGULA\n"); }

.                        { fprintf(stderr, "Erro léxico: Caractere inválido '%s' na linha %d\n", yytext, yylineno); exit(1); }

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro léxico: %s\n", s);
}
