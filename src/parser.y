%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern int yylex();
extern int yylineno;
extern char* yytext;
void yyerror(const char* s);
%}

%union {
    int ival;
    char* sval;
}

%token CONFIG REPITA FIM VAR
%token INTEIRO BOOLEANO TEXTO
%token SE SENAO ENTAO ENQUANTO ESPERAR
%token LIGAR DESLIGAR LERDIGITAL LERANALOGICO
%token CONFIGURAR COMO SAIDA ENTRADA
%token CONFIGURAR_PWM AJUSTAR_PWM FREQUENCIA CANAL RESOLUCAO
%token COM VALOR
%token CONECTAR_WIFI SENHA SSID
%token ESCREVER_SERIAL LER_SERIAL CONFIGURAR_SERIAL
%token ENVIAR_HTTP
%token IGUAL DIFERENTE MENOR MAIOR MENORIGUAL MAIORIGUAL
%token MAIS MENOS MULTIPLICACAO DIVISAO
%token ATRIBUICAO PONTO_E_VIRGULA DOIS_PONTOS

%token <ival> NUM
%token <sval> ID STRING

%left MAIS MENOS
%left MULTIPLICACAO DIVISAO
%nonassoc MENOR MAIOR MENORIGUAL MAIORIGUAL IGUAL DIFERENTE

%%

programa
    : declaracoes bloco_config bloco_repita
    ;

declaracoes
    : 
    | declaracao declaracoes
    ;

declaracao
    : VAR tipo DOIS_PONTOS lista_ids PONTO_E_VIRGULA
    ;

tipo
    : INTEIRO
    | BOOLEANO
    | TEXTO
    ;

lista_ids
    : ID
    | ID ',' lista_ids
    ;

bloco_config
    : CONFIG comandos FIM
    ;

bloco_repita
    : REPITA comandos FIM
    ;

comandos
    : 
    | comando comandos
    ;

comando
    : atribuicao
    | comando_gpio
    | comando_pwm
    | comando_wifi
    | comando_serial
    | comando_http
    | comando_esperar
    | comando_condicional
    | comando_enquanto
    ;

atribuicao
    : ID ATRIBUICAO expressao PONTO_E_VIRGULA
    ;

comando_gpio
    : CONFIGURAR ID COMO SAIDA PONTO_E_VIRGULA
    | CONFIGURAR ID COMO ENTRADA PONTO_E_VIRGULA
    | LIGAR ID PONTO_E_VIRGULA
    | DESLIGAR ID PONTO_E_VIRGULA
    | ID ATRIBUICAO LERDIGITAL ID PONTO_E_VIRGULA
    | ID ATRIBUICAO LERANALOGICO ID PONTO_E_VIRGULA
    ;

comando_pwm
    : CONFIGURAR_PWM ID COM FREQUENCIA expressao RESOLUCAO expressao PONTO_E_VIRGULA
    | AJUSTAR_PWM ID COM VALOR expressao PONTO_E_VIRGULA
    ;

comando_wifi
    : CONECTAR_WIFI ID ID PONTO_E_VIRGULA
    ;

comando_serial
    : CONFIGURAR_SERIAL expressao PONTO_E_VIRGULA
    | ESCREVER_SERIAL expressao PONTO_E_VIRGULA
    | ID ATRIBUICAO LER_SERIAL PONTO_E_VIRGULA
    ;

comando_http
    : ENVIAR_HTTP expressao expressao PONTO_E_VIRGULA
    ;

comando_esperar
    : ESPERAR expressao PONTO_E_VIRGULA
    ;

comando_condicional
    : SE expressao ENTAO comandos FIM
    | SE expressao ENTAO comandos SENAO comandos FIM
    ;

comando_enquanto
    : ENQUANTO comandos FIM
    ;

expressao
    : termo
    | expressao MAIS termo
    | expressao MENOS termo
    | expressao MULTIPLICACAO termo
    | expressao DIVISAO termo
    | expressao MENOR termo
    | expressao MAIOR termo
    | expressao MENORIGUAL termo
    | expressao MAIORIGUAL termo
    | expressao IGUAL termo
    | expressao DIFERENTE termo
    ;

termo
    : ID
    | NUM
    | STRING
    ;

%%

void yyerror(const char* s) {
    fprintf(stderr, "Erro sintático na linha %d: %s\n", yylineno, s);
    exit(1);
}

int main() {
    yyparse();
    printf("Análise sintática concluída com sucesso!\n");
    return 0;
}