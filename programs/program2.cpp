#include <Arduino.h>
#include <WiFi.h>

int ledPin;
int brilho;
String ssid;
String senha;

void setup() {
    Serial.begin(115200);
    ledPin = 2;
    ssid = "MinhaRedeWiFi";
    senha = "MinhaSenhaWiFi";
    pinMode(ledPin, OUTPUT);
    ledcSetup(0, 5000, 8);
    ledcAttachPin(ledPin, 0);
    WiFi.begin(ssid.c_str(), senha.c_str());
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
    }
}

void loop() {
    brilho = 128;
    ledcWrite(ledPin, brilho);
    delay(1000);
    brilho = 0;
    ledcWrite(ledPin, brilho);
    delay(1000);
}

