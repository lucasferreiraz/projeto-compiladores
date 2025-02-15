#include <Arduino.h>
#include <WiFi.h>

int ledVermelho;
int ledAmarelo;
int ledVerde;

void setup() {
    Serial.begin(115200);
    ledVermelho = 13;
    ledAmarelo = 12;
    ledVerde = 14;
    pinMode(ledVermelho, OUTPUT);
    pinMode(ledAmarelo, OUTPUT);
    pinMode(ledVerde, OUTPUT);
}

void loop() {
    digitalWrite(ledVerde, HIGH);
    digitalWrite(ledAmarelo, LOW);
    digitalWrite(ledVermelho, LOW);
    delay(2000);
    digitalWrite(ledVerde, LOW);
    digitalWrite(ledAmarelo, HIGH);
    digitalWrite(ledVermelho, LOW);
    delay(2000);
    digitalWrite(ledVerde, LOW);
    digitalWrite(ledAmarelo, LOW);
    digitalWrite(ledVermelho, HIGH);
    delay(2000);
}

