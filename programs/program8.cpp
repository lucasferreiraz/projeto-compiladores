#include <Arduino.h>
#include <WiFi.h>

int ledPin = 2;
int contador = 0;

void setup() {
    Serial.begin(115200);
    pinMode(ledPin, OUTPUT);
}

void loop() {
    while(1) {
    digitalWrite(ledPin, HIGH);
    delay(500);
    digitalWrite(ledPin, LOW);
    delay(500);
    contador = contador + 1;
    if (contador == 5) {
    break;
    }
    }
    contador = 0;
    delay(3000);
}

