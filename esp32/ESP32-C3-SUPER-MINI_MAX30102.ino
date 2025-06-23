#include <WiFi.h>
#include <HTTPClient.h>
#include <Arduino_JSON.h>
#include <Wire.h>
#include "MAX30105.h"
#include "heartRate.h"

// --- KREDENSIAL DAN KONFIGURASI ---
const char* ssid = "SSID_WIFI";
const char* password = "SSID_PASSWORD";
const char* serverName = "URL_API";

unsigned long lastUploadTime = 0;
const long uploadInterval = 10000;  // 10 detik

MAX30105 particleSensor; 

// --- Variabel global untuk sensor ---
const byte RATE_SIZE = 4;
byte rates[RATE_SIZE];
byte rateSpot = 0;
long lastBeat = 0;
float beatsPerMinute;
float beatAvg;
const int SPO2_SAMPLES = 100;
long irBuffer[SPO2_SAMPLES];
long redBuffer[SPO2_SAMPLES];
int bufferIdx = 0;
float spo2 = 0;

void setup() {
  Serial.begin(115200);
  delay(100);

  // Koneksi ke WiFi
  Serial.println();
  Serial.print("Menghubungkan ke WiFi: ");
  Serial.println(ssid);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("WiFi terhubung!");
  Serial.print("Alamat IP: ");
  Serial.println(WiFi.localIP());
  Serial.println("========================================");

  // Inisialisasi Sensor
  Serial.println("Initializing Pulse Oximeter...");
  if (!particleSensor.begin(Wire, I2C_SPEED_FAST)) {
    Serial.println("MAX30102 was not found. Please check wiring/power.");
    while (1)
      ;
  }
  byte ledBrightness = 0x1F;
  particleSensor.setup();
  particleSensor.setPulseAmplitudeRed(ledBrightness);
  particleSensor.setPulseAmplitudeIR(ledBrightness);
  Serial.println("Place your index finger on the sensor with steady pressure.");
}

void loop() {
  irBuffer[bufferIdx] = particleSensor.getIR();
  redBuffer[bufferIdx] = particleSensor.getRed();
  bufferIdx++;

  if (bufferIdx >= SPO2_SAMPLES) {
    bufferIdx = 0;

    long ir_max = 0, ir_min = 0x7FFFFFFF;
    long red_max = 0, red_min = 0x7FFFFFFF;
    for (int i = 0; i < SPO2_SAMPLES; i++) {
      if (irBuffer[i] > ir_max) ir_max = irBuffer[i];
      if (irBuffer[i] < ir_min) ir_min = irBuffer[i];
      if (redBuffer[i] > red_max) red_max = redBuffer[i];
      if (redBuffer[i] < red_min) red_min = redBuffer[i];
    }
    float ir_ac = ir_max - ir_min;
    float ir_dc = (ir_max + ir_min) / 2.0;
    float red_ac = red_max - red_min;
    float red_dc = (red_max + red_min) / 2.0;
    float R = (red_ac / red_dc) / (ir_ac / ir_dc);
    spo2 = 104.0 - 17.0 * R;
    if (spo2 > 100.0) spo2 = 100.0;
    if (spo2 < 80.0) spo2 = 80.0;
    long currentIR = irBuffer[SPO2_SAMPLES - 1];

    Serial.print("BPM=");
    Serial.print(beatsPerMinute, 1);
    Serial.print(", ");
    Serial.print("Avg BPM=");
    Serial.print(beatAvg, 1);
    Serial.print(", ");
    Serial.print("SpO2=");
    if (currentIR < 50000) {
      Serial.print("--");
    } else {
      Serial.print(spo2, 1);
      Serial.print("%");
    }
    Serial.print(", IR=");
    Serial.print(currentIR);
    if (currentIR < 50000) { Serial.print(" -> No finger?"); }
    Serial.println();

    if (millis() - lastUploadTime > uploadInterval) {
      if (currentIR >= 50000) {

        // ==========================================================
        // --- FORMAT JSON DENGAN SEMUA DATA SEBAGAI FLOAT ---
        JSONVar postData;
        postData["bpm"] = beatsPerMinute;
        postData["avg_bpm"] = beatAvg;
        postData["spo2"] = spo2;
        // ==========================================================

        String jsonString = JSON.stringify(postData);

        HTTPClient http;
        http.begin(serverName);
        http.addHeader("Content-Type", "application/json");

        Serial.println("---------------------------------");
        Serial.print("Mengirim data ke API: ");
        Serial.println(jsonString);
        int httpResponseCode = http.POST(jsonString);

        if (httpResponseCode > 0) {
          Serial.print("Status Kirim: Berhasil! Kode Respons: ");
          Serial.println(httpResponseCode);
        } else {
          Serial.print("Status Kirim: Gagal! Error: ");
          Serial.println(http.errorToString(httpResponseCode).c_str());
        }

        http.end();
        Serial.println("---------------------------------");
        lastUploadTime = millis();

      } else {
        lastUploadTime = millis();
      }
    }
  }

  // Kalkulasi BPM
  if (checkForBeat(irBuffer[bufferIdx - 1]) == true) {
    long delta = millis() - lastBeat;
    lastBeat = millis();
    beatsPerMinute = 60 / (delta / 1000.0);
    if (beatsPerMinute < 255 && beatsPerMinute > 40) {
      rates[rateSpot++] = (byte)beatsPerMinute;
      rateSpot %= RATE_SIZE;

      // Kalkulasi rata-rata
      float totalBpm = 0;  // Gunakan float untuk total
      for (byte x = 0; x < RATE_SIZE; x++) {
        totalBpm += rates[x];
      }
      beatAvg = totalBpm / RATE_SIZE;
    }
  }

  delay(10);
}