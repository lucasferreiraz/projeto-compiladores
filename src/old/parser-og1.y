%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int yylineno;
extern char* yytext;
void yyerror(const char* s);

char current_type[20];

FILE* output;
int pwm_channel = 0;

// Função auxiliar para gerar cabeçalho do arquivo
void generate_header() {
    fprintf(output, "#include <Arduino.h>\n");
    fprintf(output, "#include <WiFi.h>\n\n");
}

// Função auxiliar para iniciar o setup
void start_setup() {
    fprintf(output, "void setup() {\n");
    fprintf(output, "    Serial.begin(115200);\n");
}

// Função auxiliar para iniciar o loop
void start_loop() {
    fprintf(output, "void loop() {\n");
}

// Função auxiliar para fechar blocos
void end_block() {
    fprintf(output, "}\n\n");
}

%}

%union {
    int ival;
    char* sval;
}

/* Tokens - mantidos os mesmos */
%token CONFIG REPITA FIM VAR
%token INTEIRO BOOLEANO TEXTO
%token SE SENAO ENTAO ENQUANTO ESPERAR
%token LIGAR DESLIGAR LERDIGITAL LERANALOGICO
%token CONFIGURAR COMO SAIDA ENTRADA
%token CONFIGURAR_PWM AJUSTAR_PWM FREQUENCIA CANAL RESOLUCAO
%token COM VALOR
%token CONECTAR_WIFI
%token ESCREVER_SERIAL LER_SERIAL CONFIGURAR_SERIAL
%token ENVIAR_HTTP
%token IGUAL DIFERENTE MENOR MAIOR MENORIGUAL MAIORIGUAL
%token MAIS MENOS MULTIPLICACAO DIVISAO
%token ATRIBUICAO VIRGULA PONTO_E_VIRGULA DOIS_PONTOS 

%token <ival> NUM
%token <sval> ID STRING

%left MAIS MENOS
%left MULTIPLICACAO DIVISAO
%nonassoc MENOR MAIOR MENORIGUAL MAIORIGUAL IGUAL DIFERENTE

%%

programa
    : { 
        output = fopen("output.cpp", "w");
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
    : /* vazio */
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
        if (strcmp(current_type, "inteiro") == 0) {
            fprintf(output, "int %s;\n", $1);
        } else if (strcmp(current_type, "booleano") == 0) {
            fprintf(output, "bool %s;\n", $1);
        } else if (strcmp(current_type, "texto") == 0) {
            fprintf(output, "String %s;\n", $1);
        }
    }
    | ID ATRIBUICAO NUM {
        if (strcmp(current_type, "inteiro") == 0) {
            fprintf(output, "int %s = %d;\n", $1, $3);
        } else if (strcmp(current_type, "booleano") == 0) {
            fprintf(output, "bool %s = %d;\n", $1, $3);
        } else if (strcmp(current_type, "texto") == 0) {
            fprintf(output, "String %s = %d;\n", $1, $3);
        }
    }
    | ID ATRIBUICAO STRING {
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
    : CONFIG comandos FIM
    ;

bloco_repita
    : REPITA comandos FIM
    ;

comandos
    : /* vazio */
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
    : ID ATRIBUICAO expressao PONTO_E_VIRGULA {
        fprintf(output, "    %s = %s;\n", $1, $<sval>3);
    }
    ;

comando_gpio
    : CONFIGURAR ID COMO SAIDA PONTO_E_VIRGULA {
        fprintf(output, "    pinMode(%s, OUTPUT);\n", $2);
    }
    | CONFIGURAR ID COMO ENTRADA PONTO_E_VIRGULA {
        fprintf(output, "    pinMode(%s, INPUT);\n", $2);
    }
    | LIGAR ID PONTO_E_VIRGULA {
        fprintf(output, "    digitalWrite(%s, HIGH);\n", $2);
    }
    | DESLIGAR ID PONTO_E_VIRGULA {
        fprintf(output, "    digitalWrite(%s, LOW);\n", $2);
    }
    | ID ATRIBUICAO LERDIGITAL ID PONTO_E_VIRGULA {
        fprintf(output, "    %s = digitalRead(%s);\n", $1, $4);
    }
    | ID ATRIBUICAO LERANALOGICO ID PONTO_E_VIRGULA {
        fprintf(output, "    %s = analogRead(%s);\n", $1, $4);
    }
    ;

comando_pwm
    : CONFIGURAR_PWM ID COM FREQUENCIA expressao RESOLUCAO expressao PONTO_E_VIRGULA {
        fprintf(output, "    ledcSetup(%d, %s, %s);\n", pwm_channel, $<sval>5, $<sval>7);
        fprintf(output, "    ledcAttachPin(%s, %d);\n", $2, pwm_channel);
        pwm_channel++;
    }
    | AJUSTAR_PWM ID COM VALOR expressao PONTO_E_VIRGULA {
        fprintf(output, "    ledcWrite(%s, %s);\n", $2, $<sval>5);
    }
    ;

comando_wifi
    : CONECTAR_WIFI ID ID PONTO_E_VIRGULA {
        fprintf(output, "    WiFi.begin(%s.c_str(), %s.c_str());\n", $2, $3);
        fprintf(output, "    while (WiFi.status() != WL_CONNECTED) {\n");
        fprintf(output, "        delay(500);\n");
        fprintf(output, "        Serial.print(\".\");\n");
        fprintf(output, "    }\n");
    }
    ;

comando_serial
    : CONFIGURAR_SERIAL expressao PONTO_E_VIRGULA {
        fprintf(output, "    Serial.begin(%s);\n", $<sval>2);
    }
    | ESCREVER_SERIAL expressao PONTO_E_VIRGULA {
        fprintf(output, "    Serial.println(%s);\n", $<sval>2);
    }
    | ID ATRIBUICAO LER_SERIAL PONTO_E_VIRGULA {
        fprintf(output, "    if(Serial.available()) {\n");
        fprintf(output, "        %s = Serial.readString();\n", $1);
        fprintf(output, "    }\n");
    }
    ;

comando_http
    : ENVIAR_HTTP expressao expressao PONTO_E_VIRGULA {
        fprintf(output, "    HTTPClient http;\n");
        fprintf(output, "    http.begin(%s);\n", $<sval>2);
        fprintf(output, "    http.POST(%s);\n", $<sval>3);
        fprintf(output, "    http.end();\n");
    }
    ;

comando_esperar
    : ESPERAR expressao PONTO_E_VIRGULA {
        fprintf(output, "    delay(%s);\n", $<sval>2);
    }
    ;

comando_condicional
    : SE expressao ENTAO comandos FIM {
        fprintf(output, "    if (%s) {\n", $<sval>2);
        // Comandos já foram gerados
        fprintf(output, "    }\n");
    }
    | SE expressao ENTAO comandos SENAO comandos FIM {
        fprintf(output, "    if (%s) {\n", $<sval>2);
        // Comandos do if já foram gerados
        fprintf(output, "    } else {\n");
        // Comandos do else já foram gerados
        fprintf(output, "    }\n");
    }
    ;

comando_enquanto
    : ENQUANTO comandos FIM {
        fprintf(output, "    while(1) {\n");
        // Comandos já foram gerados
        fprintf(output, "    }\n");
    }
    ;

expressao
    : termo { $<sval>$ = $<sval>1; }
    | expressao MAIS termo { 
        char temp[100];
        sprintf(temp, "%s + %s", $<sval>1, $<sval>3);
        $<sval>$ = strdup(temp);
    }
    | expressao MENOS termo {
        char temp[100];
        sprintf(temp, "%s - %s", $<sval>1, $<sval>3);
        $<sval>$ = strdup(temp);
    }
    | expressao MULTIPLICACAO termo {
        char temp[100];
        sprintf(temp, "%s * %s", $<sval>1, $<sval>3);
        $<sval>$ = strdup(temp);
    }
    | expressao DIVISAO termo {
        char temp[100];
        sprintf(temp, "%s / %s", $<sval>1, $<sval>3);
        $<sval>$ = strdup(temp);
    }
    | expressao MENOR termo {
        char temp[100];
        sprintf(temp, "%s < %s", $<sval>1, $<sval>3);
        $<sval>$ = strdup(temp);
    }
    | expressao MAIOR termo {
        char temp[100];
        sprintf(temp, "%s > %s", $<sval>1, $<sval>3);
        $<sval>$ = strdup(temp);
    }
    | expressao MENORIGUAL termo {
        char temp[100];
        sprintf(temp, "%s <= %s", $<sval>1, $<sval>3);
        $<sval>$ = strdup(temp);
    }
    | expressao MAIORIGUAL termo {
        char temp[100];
        sprintf(temp, "%s >= %s", $<sval>1, $<sval>3);
        $<sval>$ = strdup(temp);
    }
    | expressao IGUAL termo {
        char temp[100];
        sprintf(temp, "%s == %s", $<sval>1, $<sval>3);
        $<sval>$ = strdup(temp);
    }
    | expressao DIFERENTE termo {
        char temp[100];
        sprintf(temp, "%s != %s", $<sval>1, $<sval>3);
        $<sval>$ = strdup(temp);
    }
    ;

termo
    : ID { $<sval>$ = $1; }
    | NUM { 
        char temp[20];
        sprintf(temp, "%d", $<ival>1);
        $<sval>$ = strdup(temp);
    }
    | STRING { $<sval>$ = $1; }
    ;

%%

void yyerror(const char* s) {
    fprintf(stderr, "Erro sintático na linha %d: %s\n", yylineno, s);
    exit(1);
}

int main() {
    yyparse();
    printf("Análise sintática e geração de código concluídas com sucesso!\n");
    return 0;
}