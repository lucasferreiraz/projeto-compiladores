%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

void yyerror(const char *s);
int yylex(void);
%}

%option noyywrap
%option yylineno

DIGITO  [0-9]
LETRA   [a-zA-Z_]
ID      {LETRA}({LETRA}|{DIGITO})*
NUM     {DIGITO}+
STRING  \"[^\"]*\"

%%

"config"        { return CONFIG; }
"repita"        { return REPITA; }
"fim"           { return FIM; }
"var"           { return VAR; }
"inteiro"       { return INTEIRO; }
"booleano"      { return BOOLEANO; }
"texto"         { return TEXTO; }
"se"            { return SE; }
"senao"         { return SENAO; }
"entao"         { return ENTAO; }
"enquanto"      { return ENQUANTO; }
"esperar"       { return ESPERAR; }

"ligar"         { return LIGAR; }
"desligar"      { return DESLIGAR; }
"lerDigital"    { return LERDIGITAL; }
"lerAnalogico"  { return LERANALOGICO; }
"configurar"    { return CONFIGURAR; }
"como"          { return COMO; }
"saida"         { return SAIDA; }
"entrada"       { return ENTRADA; }

"configurarPWM" { return CONFIGURAR_PWM; }
"ajustarPWM"    { return AJUSTAR_PWM; }
"frequencia"    { return FREQUENCIA; }
"resolucao"     { return RESOLUCAO; }
"com"           { return COM; }
"valor"         { return VALOR; }

"conectarWifi"  { return CONECTAR_WIFI; }

"escreverSerial" { return ESCREVER_SERIAL; }
"lerSerial"      { return LER_SERIAL; }
"configurarSerial" { return CONFIGURAR_SERIAL; }

"enviarHttp"    { return ENVIAR_HTTP; }

"=="            { return IGUAL; }
"!="            { return DIFERENTE; }
"<"             { return MENOR; }
">"             { return MAIOR; }
"<="            { return MENORIGUAL; }
">="            { return MAIORIGUAL; }

"+"             { return MAIS; }
"-"             { return MENOS; }
"*"             { return MULTIPLICACAO; }
"/"             { return DIVISAO; }

"="             { return ATRIBUICAO; }
";"             { return PONTO_E_VIRGULA; }
","             { return VIRGULA; }
":"             { return DOIS_PONTOS; }

{ID}            { yylval.sval = strdup(yytext); return ID; }
{NUM}           { yylval.ival = atoi(yytext); return NUM; }
{STRING}        { yylval.sval = strdup(yytext); return STRING; }

"//".*\n        ;
[ \t\n]+        ;

.               { fprintf(stderr, "Erro léxico: Caractere inválido '%s' na linha %d\n", yytext, yylineno); exit(1); }

%%
