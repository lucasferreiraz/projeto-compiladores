%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"
#include "pin_manager.h"
#include "type_checker.h"
#include "code_generator.h"

extern int yylex();
extern int yylineno;
extern char* yytext;
extern FILE* yyin;
void yyerror(const char* s);

%}

%union {
    int ival;
    char* sval;
}

%token CONFIG REPITA FIM VAR
%token INTEIRO BOOLEANO TEXTO
%token SE SENAO ENTAO ENQUANTO QUEBRAR ESPERAR
%token LIGAR DESLIGAR LERDIGITAL LERANALOGICO
%token CONFIGURAR COMO SAIDA ENTRADA
%token CONFIGURAR_PWM AJUSTAR_PWM FREQUENCIA RESOLUCAO
%token COM VALOR
%token CONECTAR_WIFI
%token ESCREVER_SERIAL LER_SERIAL CONFIGURAR_SERIAL
%token ENVIAR_HTTP
%token IGUAL DIFERENTE MENOR MAIOR MENORIGUAL MAIORIGUAL
%token MAIS MENOS MULTIPLICACAO DIVISAO
%token ATRIBUICAO VIRGULA PONTO_E_VIRGULA DOIS_PONTOS 

%token <ival> NUM
%token <sval> ID STRING

%type <sval> comando_gpio comando_pwm comando_wifi comando_serial
%type <sval> comando_http comando_esperar comando_condicional comando_enquanto comando_quebrar
%type <sval> atribuicao expressao termo bloco_comandos comando

%left MAIS MENOS
%left MULTIPLICACAO DIVISAO
%nonassoc MENOR MAIOR MENORIGUAL MAIORIGUAL IGUAL DIFERENTE

%%

programa
    : { 
        output = fopen(output_filename, "w");
        generate_header(); 
      }
      declaracoes 
      { start_setup(); }
      bloco_config 
      { 
        end_block();
        start_loop();
      }
      bloco_repita
      { 
        end_block();
        fclose(output);
      }
    ;

declaracoes
    : 
    | declaracao declaracoes
    ;

declaracao
    : VAR tipo DOIS_PONTOS lista_ids PONTO_E_VIRGULA
    ;

tipo
    : INTEIRO { strcpy(current_type, "inteiro"); }
    | BOOLEANO { strcpy(current_type, "booleano"); }
    | TEXTO { strcpy(current_type, "texto"); }
    ;

lista_ids
    : id_com_atribuicao
    | id_com_atribuicao VIRGULA lista_ids
    ;

id_com_atribuicao
    : ID {
        add_symbol($1, current_type, yylineno);
        if (strcmp(current_type, "inteiro") == 0) {
            fprintf(output, "int %s;\n", $1);
        } else if (strcmp(current_type, "booleano") == 0) {
            fprintf(output, "bool %s;\n", $1);
        } else if (strcmp(current_type, "texto") == 0) {
            fprintf(output, "String %s;\n", $1);
        }
    }
    | ID ATRIBUICAO NUM {
        VarType type = str_to_type(current_type);
        char num_str[20];
        sprintf(num_str, "%d", $3);
        check_value_type($1, num_str, type, yylineno);
        add_symbol($1, current_type, yylineno);
        if (strcmp(current_type, "inteiro") == 0) {
            fprintf(output, "int %s = %d;\n", $1, $3);
        } else if (strcmp(current_type, "booleano") == 0) {
            fprintf(output, "bool %s = %d;\n", $1, $3);
        } else if (strcmp(current_type, "texto") == 0) {
            fprintf(output, "String %s = %d;\n", $1, $3);
        }
    }
    | ID ATRIBUICAO STRING {
        VarType type = str_to_type(current_type);
        check_value_type($1, $3, type, yylineno);
        add_symbol($1, current_type, yylineno);
        if (strcmp(current_type, "inteiro") == 0) {
            fprintf(output, "int %s = %s;\n", $1, $3);
        } else if (strcmp(current_type, "booleano") == 0) {
            fprintf(output, "bool %s = %s;\n", $1, $3);
        } else if (strcmp(current_type, "texto") == 0) {
            fprintf(output, "String %s = %s;\n", $1, $3);
        }
    }
    ;

bloco_config
    : CONFIG setup_comandos FIM
    ;

setup_comandos
    : 
    | setup_comando setup_comandos
    ;

setup_comando
    : atribuicao {
        fprintf(output, "    %s", $1);
    }
    | comando_gpio {
        fprintf(output, "    %s", $1);
    }
    | comando_pwm {
        fprintf(output, "    %s", $1);
    }
    | comando_wifi {
        fprintf(output, "    %s", $1);
    }
    | comando_serial {
        fprintf(output, "    %s", $1);
    }
    ;

bloco_repita
    : REPITA comandos FIM
    ;

comandos
    : 
    | comando {
        fprintf(output, "    %s", $1);
    } comandos
    ;

comando
    : atribuicao {
        $$ = $1;
    }
    | comando_gpio {
        $$ = $1;
    }
    | comando_pwm {
        $$ = $1;
    }
    | comando_wifi {
        $$ = $1;
    }
    | comando_serial {
        $$ = $1;
    }
    | comando_http {
        $$ = $1;
    }
    | comando_esperar {
        $$ = $1;
    }
    | comando_condicional {
        $$ = $1;
    }
    | comando_enquanto {
        $$ = $1;
    }
    | comando_quebrar { 
        $$ = $1; 
    }
    ;

atribuicao
    : ID ATRIBUICAO expressao PONTO_E_VIRGULA {
        check_variable($1, yylineno);
        char* var_type = get_variable_type($1);
        VarType type = str_to_type(get_variable_type($1));
        check_value_type($1, $3, type, yylineno);
        char temp[100];
        sprintf(temp, "%s = %s;\n", $1, $3);
        $$ = strdup(temp);
    }
    ;

comando_gpio
    : CONFIGURAR ID COMO SAIDA PONTO_E_VIRGULA {
        check_variable($2, yylineno);
        set_pin_mode($2, PIN_OUTPUT);
        char temp[100];
        sprintf(temp, "pinMode(%s, OUTPUT);\n", $2);
        $$ = strdup(temp);
    }
    | CONFIGURAR ID COMO ENTRADA PONTO_E_VIRGULA {
        check_variable($2, yylineno);
        set_pin_mode($2, PIN_INPUT);
        char temp[100];
        sprintf(temp, "pinMode(%s, INPUT);\n", $2);
        $$ = strdup(temp);
    }
    | LIGAR ID PONTO_E_VIRGULA {
        check_variable($2, yylineno);
        check_pin_mode($2, PIN_OUTPUT, "ligar", yylineno);
        char temp[100];
        sprintf(temp, "digitalWrite(%s, HIGH);\n", $2);
        $$ = strdup(temp);
    }
    | DESLIGAR ID PONTO_E_VIRGULA {
        check_variable($2, yylineno);
        check_pin_mode($2, PIN_OUTPUT, "desligar", yylineno);
        char temp[100];
        sprintf(temp, "digitalWrite(%s, LOW);\n", $2);
        $$ = strdup(temp);
    }
    | ID ATRIBUICAO LERDIGITAL ID PONTO_E_VIRGULA {
        check_variable($1, yylineno);
        check_variable($4, yylineno);
        check_pin_mode($4, PIN_INPUT, "lerDigital", yylineno);
        char temp[100];
        sprintf(temp, "%s = digitalRead(%s);\n", $1, $4);
        $$ = strdup(temp);
    }
    | ID ATRIBUICAO LERANALOGICO ID PONTO_E_VIRGULA {
        check_variable($1, yylineno);
        check_variable($4, yylineno);
        check_pin_mode($4, PIN_INPUT, "lerAnalogico", yylineno);
        char temp[100];
        sprintf(temp, "%s = analogRead(%s);\n", $1, $4);
        $$ = strdup(temp);
    }
    ;

comando_pwm
    : CONFIGURAR_PWM ID COM FREQUENCIA expressao RESOLUCAO expressao PONTO_E_VIRGULA {
        check_variable($2, yylineno);
        set_pin_mode($2, PIN_PWM);
        char temp[200];
        sprintf(temp, "ledcSetup(%d, %s, %s);\n    ledcAttachPin(%s, %d);\n", 
                pwm_channel, $5, $7, $2, pwm_channel);
        pwm_channel++;
        $$ = strdup(temp);
    }
    | AJUSTAR_PWM ID COM VALOR expressao PONTO_E_VIRGULA {
        check_variable($2, yylineno);
        check_pin_mode($2, PIN_PWM, "ajustarPWM", yylineno);
        char temp[100];
        sprintf(temp, "ledcWrite(%s, %s);\n", $2, $5);
        $$ = strdup(temp);
    }
    ;

comando_wifi
    : CONECTAR_WIFI ID ID PONTO_E_VIRGULA {
        check_variable($2, yylineno);
        check_variable($3, yylineno);
        char temp[500];
        sprintf(temp, "WiFi.begin(%s.c_str(), %s.c_str());\n"
                     "    while (WiFi.status() != WL_CONNECTED) {\n"
                     "        delay(500);\n"
                     "        Serial.print(\".\");\n"
                     "    }\n", $2, $3);
        $$ = strdup(temp);
    }
    ;

comando_serial
    : CONFIGURAR_SERIAL expressao PONTO_E_VIRGULA {
        char temp[100];
        sprintf(temp, "Serial.begin(%s);\n", $2);
        $$ = strdup(temp);
    }
    | ESCREVER_SERIAL expressao PONTO_E_VIRGULA {
        char temp[100];
        sprintf(temp, "Serial.println(%s);\n", $2);
        $$ = strdup(temp);
    }
    | ID ATRIBUICAO LER_SERIAL PONTO_E_VIRGULA {
        check_variable($1, yylineno);
        char temp[200];
        sprintf(temp, "if(Serial.available()) {\n"
                     "        %s = Serial.readString();\n"
                     "    }\n", $1);
        $$ = strdup(temp);
    }
    ;

comando_http
    : ENVIAR_HTTP expressao expressao PONTO_E_VIRGULA {
        char temp[300];
        sprintf(temp, "HTTPClient http;\n"
                     "    http.begin(%s);\n"
                     "    http.POST(%s);\n"
                     "    http.end();\n", $2, $3);
        $$ = strdup(temp);
    }
    ;

comando_esperar
    : ESPERAR expressao PONTO_E_VIRGULA {
        char temp[100];
        sprintf(temp, "delay(%s);\n", $2);
        $$ = strdup(temp);
    }
    ;

comando_condicional
    : SE expressao ENTAO bloco_comandos FIM {
        char temp[1000];
        sprintf(temp, "if (%s) {\n%s    }\n", $2, $4);
        $$ = strdup(temp);
    }
    | SE expressao ENTAO bloco_comandos SENAO bloco_comandos FIM {
        char temp[1000];
        sprintf(temp, "if (%s) {\n%s    } else {\n%s    }\n", $2, $4, $6);
        $$ = strdup(temp);
    }
    ;

comando_enquanto
    : ENQUANTO bloco_comandos FIM {
        char temp[1000];
        sprintf(temp, "while(1) {\n%s    }\n", $2);
        $$ = strdup(temp);
    }
    ;

comando_quebrar
    : QUEBRAR PONTO_E_VIRGULA {
        char temp[100];
        sprintf(temp, "break;\n");
        $$ = strdup(temp);
    }
    ;

bloco_comandos
    : { $$ = strdup(""); }
    | comando bloco_comandos {
        char temp[1000];
        sprintf(temp, "    %s%s", $1, $2);
        $$ = strdup(temp);
    }
    ;

expressao
    : termo { $$ = $1; }
    | expressao MAIS termo { 
        check_operation_type($1, '+', yylineno);
        check_operation_type($3, '+', yylineno);
        char temp[100];
        sprintf(temp, "%s + %s", $1, $3);
        $$ = strdup(temp);
    }
    | expressao MENOS termo {
        check_operation_type($1, '-', yylineno);
        check_operation_type($3, '-', yylineno);
        char temp[100];
        sprintf(temp, "%s - %s", $1, $3);
        $$ = strdup(temp);
    }
    | expressao MULTIPLICACAO termo {
        check_operation_type($1, '*', yylineno);
        check_operation_type($3, '*', yylineno);
        char temp[100];
        sprintf(temp, "%s * %s", $1, $3);
        $$ = strdup(temp);
    }
    | expressao DIVISAO termo {
        check_operation_type($1, '/', yylineno);
        check_operation_type($3, '/', yylineno);
        char temp[100];
        sprintf(temp, "%s / %s", $1, $3);
        $$ = strdup(temp);
    }
    | expressao MENOR termo {
        char temp[100];
        sprintf(temp, "%s < %s", $1, $3);
        $$ = strdup(temp);
    }
    | expressao MAIOR termo {
        char temp[100];
        sprintf(temp, "%s > %s", $1, $3);
        $$ = strdup(temp);
    }
    | expressao MENORIGUAL termo {
        char temp[100];
        sprintf(temp, "%s <= %s", $1, $3);
        $$ = strdup(temp);
    }
    | expressao MAIORIGUAL termo {
        char temp[100];
        sprintf(temp, "%s >= %s", $1, $3);
        $$ = strdup(temp);
    }
    | expressao IGUAL termo {
        char temp[100];
        sprintf(temp, "%s == %s", $1, $3);
        $$ = strdup(temp);
    }
    | expressao DIFERENTE termo {
        char temp[100];
        sprintf(temp, "%s != %s", $1, $3);
        $$ = strdup(temp);
    }
    ;

termo
    : ID { 
        $$ = $1;
        check_variable($1, yylineno);
    }
    | NUM { 
        char temp[20];
        sprintf(temp, "%d", $1);
        $$ = strdup(temp);
    }
    | STRING { $$ = $1; }
    ;

%%

void yyerror(const char* s) {
    fprintf(stderr, "Erro sintático na linha %d: %s\n", yylineno, s);
    exit(1);
}

int main(int argc, char** argv) {
    if (argc != 2) {
        fprintf(stderr, "Uso: %s <arquivo.esp>\n", argv[0]);
        return 1;
    }

    generate_output_filename(argv[1]);

    if (!(yyin = fopen(argv[1], "r"))) {
        fprintf(stderr, "Não foi possível abrir o arquivo %s\n", argv[1]);
        return 1;
    }

    yyparse();
    fclose(yyin);
    
    printf("Análise sintática e geração de código concluídas com sucesso!\n");
    return 0;
}