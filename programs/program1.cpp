#include <Arduino.h>
#include <WiFi.h>

int ledPin = 2;

void setup() {
    Serial.begin(115200);
    ledPin = 2;
    pinMode(ledPin, OUTPUT);
}

void loop() {
    digitalWrite(ledPin, HIGH);
    delay(1000);
    digitalWrite(ledPin, LOW);
    delay(2000);
}

