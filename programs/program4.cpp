#include <Arduino.h>
#include <WiFi.h>

int ledPin;
int botao;
bool estadoBotao;

void setup() {
    Serial.begin(115200);
    ledPin = 2;
    botao = 4;
    pinMode(ledPin, OUTPUT);
    pinMode(botao, INPUT);
}

void loop() {
    estadoBotao = digitalRead(botao);
    if (estadoBotao == 1) {
    digitalWrite(ledPin, HIGH);
    } else {
    digitalWrite(ledPin, LOW);
    }
}

