/*
 * BLE Communication Module - Implementation
 *
 * Handles Bluetooth Low Energy communication with iOS app
 */

#include "ble_comms.h"
#include <ArduinoBLE.h>

// Global variables
bool bleConnected = false;

BLEService gaitService(GAIT_SERVICE_UUID);

BLEFloatCharacteristic strideLengthChar(STRIDE_LENGTH_CHAR_UUID, BLERead | BLENotify);
BLEUnsignedIntCharacteristic cadenceChar(CADENCE_CHAR_UUID, BLERead | BLENotify);
BLEByteCharacteristic strikeTypeChar(STRIKE_TYPE_CHAR_UUID, BLERead | BLENotify);
BLEByteCharacteristic batteryChar(BATTERY_CHAR_UUID, BLERead | BLENotify);

void initBLE() {
  if (!BLE.begin()) {
    Serial.println("Starting BLE failed!");
    while (1);
  }

  // Set device name
  BLE.setLocalName(BLE_DEVICE_NAME);

  // Set advertised service
  BLE.setAdvertisedService(gaitService);

  // Add characteristics to service
  gaitService.addCharacteristic(strideLengthChar);
  gaitService.addCharacteristic(cadenceChar);
  gaitService.addCharacteristic(strikeTypeChar);
  gaitService.addCharacteristic(batteryChar);

  // Add service
  BLE.addService(gaitService);

  // Set initial values
  strideLengthChar.writeValue(0.0f);
  cadenceChar.writeValue(0);
  strikeTypeChar.writeValue(MIDFOOT);
  batteryChar.writeValue(100);

  // Start advertising
  BLE.advertise();

  Serial.println("BLE service started. Device name: " + String(BLE_DEVICE_NAME));
  Serial.println("Waiting for connections...");
}

void updateBLEMetrics(float strideLength, StrikeType strikeType) {
  if (!bleConnected) {
    return;
  }

  strideLengthChar.writeValue(strideLength);
  strikeTypeChar.writeValue((uint8_t)strikeType);

  if (DEBUG_MODE) {
    Serial.print("BLE update - Stride: ");
    Serial.print(strideLength, 2);
    Serial.print(" m | Strike: ");
    Serial.println(strikeType);
  }
}

void updateBLECadence(float cadence) {
  if (!bleConnected) {
    return;
  }

  cadenceChar.writeValue((uint16_t)cadence);

  if (DEBUG_MODE) {
    Serial.print("BLE update - Cadence: ");
    Serial.print(cadence, 0);
    Serial.println(" steps/min");
  }
}

void updateBLEBattery(uint8_t batteryPercent) {
  if (!bleConnected) {
    return;
  }

  batteryChar.writeValue(batteryPercent);

  if (DEBUG_MODE) {
    Serial.print("BLE update - Battery: ");
    Serial.print(batteryPercent);
    Serial.println("%");
  }
}

void handleBLEConnection() {
  BLEDevice central = BLE.central();

  if (central) {
    if (!bleConnected) {
      bleConnected = true;
      Serial.print("Connected to central: ");
      Serial.println(central.address());
    }
  } else {
    if (bleConnected) {
      bleConnected = false;
      Serial.println("Disconnected from central");
    }
  }
}

bool isBLEConnected() {
  return bleConnected;
}
