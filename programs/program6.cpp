#include <Arduino.h>
#include <WiFi.h>

int ledPin;
int botaoPin;
bool estadoBotao;

void setup() {
    Serial.begin(115200);
    ledPin = 2;
    botaoPin = 4;
    pinMode(ledPin, OUTPUT);
    pinMode(botaoPin, INPUT);
    Serial.begin(115200);
}

void loop() {
    estadoBotao = digitalRead(botaoPin);
    if (estadoBotao == 1) {
    digitalWrite(ledPin, HIGH);
    Serial.println("Botão Pressionado - LED Ligado");
    } else {
    digitalWrite(ledPin, LOW);
    Serial.println("Botão Solto - LED Desligado");
    }
    delay(100);
}

