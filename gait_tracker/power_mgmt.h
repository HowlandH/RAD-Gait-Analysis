/*
 * Power Management Module - Header
 *
 * Handles battery monitoring and low-power modes
 */

#ifndef POWER_MGMT_H
#define POWER_MGMT_H

#include <Arduino.h>

// Initialize power management
void initPowerManagement();

// Get battery percentage (0-100)
uint8_t getBatteryPercent();

// Get battery voltage
float getBatteryVoltage();

// Enter low-power mode (wake on motion)
void enterLowPowerMode();

// Wake from low-power mode
void wakeFromMotion();

#endif // POWER_MGMT_H
