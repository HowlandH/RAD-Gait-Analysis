``/*
 * BLE Communication Module - Header
 *
 * Handles Bluetooth Low Energy communication with iOS app
 */

#ifndef BLE_COMMS_H
#define BLE_COMMS_H

#include <Arduino.h>
#include "config.h"

// Initialize BLE service and characteristics
void initBLE();

// Update BLE metrics (stride and strike type)
void updateBLEMetrics(float strideLength, StrikeType strikeType);

// Update BLE cadence characteristic
void updateBLECadence(float cadence);

// Update BLE battery characteristic
void updateBLEBattery(uint8_t batteryPercent);

// Handle BLE connection events
void handleBLEConnection();

// Check if a device is connected
bool isBLEConnected();

#endif // BLE_COMMS_H
