#include <Arduino.h>
#include <WiFi.h>

int ledPin;
int sensor;

void setup() {
    Serial.begin(115200);
    pinMode(ledPin, OUTPUT);
}

void loop() {
