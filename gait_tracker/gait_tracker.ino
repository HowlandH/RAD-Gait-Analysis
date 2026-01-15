/*
 * Gait Tracker - Main Sketch
 *
 * Running gait analysis device for Arduino Nano 33 BLE Rev2
 * Tracks stride length, foot strike patterns, and cadence
 *
 * Hardware:
 * - Arduino Nano 33 BLE Rev2
 * - MPU-6050 IMU (I2C: SDA=A4, SCL=A5)
 * - MP2636 Power Module + 3.7V LiPo Battery
 *
 * Author: Hudson's Projects
 * Date: 2026-01-13
 */

#include "config.h"
#include "imu_sensor.h"
#include "gait_detection.h"
#include "stride_length.h"
#include "cadence.h"
#include "ble_comms.h"
#include "power_mgmt.h"

// Timing variables
unsigned long lastIMURead = 0;
unsigned long lastCadenceUpdate = 0;
unsigned long lastBatteryUpdate = 0;

void setup() {
  // Initialize serial for debugging
  Serial.begin(115200);
  while (!Serial && millis() < 3000); // Wait up to 3 seconds for serial

  Serial.println("=== Gait Tracker Starting ===");

  // Initialize all modules
  Serial.println("Initializing IMU...");
  initIMU();

  Serial.println("Calibrating IMU...");
  calibrateIMU();

  Serial.println("Initializing BLE...");
  initBLE();

  Serial.println("Initializing Power Management...");
  initPowerManagement();

  Serial.println("=== Initialization Complete ===");
  Serial.println("Device ready. Waiting for BLE connection...");
}

void loop() {
  unsigned long currentTime = millis();

  // Read IMU data at 100Hz (every 10ms)
  if (currentTime - lastIMURead >= IMU_READ_INTERVAL) {
    lastIMURead = currentTime;

    float ax, ay, az, gx, gy, gz;
    readIMUData(ax, ay, az, gx, gy, gz);

    // Update orientation estimation
    updateOrientation();

    // Process gait detection
    if (detectFootStrike(az)) {
      // Classify strike type based on pitch angle
      StrikeType strike = classifyStrike(ax, ay, az, getPitchAngle());

      // Calculate stride length
      float stride = calculateStrideLength(getMaxSwingAngle());

      // Increment step count
      incrementStepCount();

      // Update BLE characteristics immediately
      updateBLEMetrics(stride, strike);

      // Debug output
      Serial.print("Strike detected: ");
      Serial.print(strike == HEEL ? "HEEL" : (strike == MIDFOOT ? "MIDFOOT" : "FOREFOOT"));
      Serial.print(" | Stride: ");
      Serial.print(stride, 2);
      Serial.println(" m");
    }
  }

  // Update cadence every second
  if (currentTime - lastCadenceUpdate >= CADENCE_UPDATE_INTERVAL) {
    lastCadenceUpdate = currentTime;

    float cadence = calculateCadence();
    updateBLECadence(cadence);

    // Debug output
    if (cadence > 0) {
      Serial.print("Cadence: ");
      Serial.print(cadence, 0);
      Serial.println(" steps/min");
    }
  }

  // Update battery level every 30 seconds
  if (currentTime - lastBatteryUpdate >= BATTERY_UPDATE_INTERVAL) {
    lastBatteryUpdate = currentTime;

    uint8_t batteryPercent = getBatteryPercent();
    updateBLEBattery(batteryPercent);
  }

  // Handle BLE connection events
  handleBLEConnection();

  // Power management - enter low power mode if stationary
  if (isStationary() && getTimeSinceLastMotion() > IDLE_TIMEOUT) {
    enterLowPowerMode();
  }

  // Small delay to maintain 100Hz loop rate
  delay(1);
}
