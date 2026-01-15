/*
 * Gait Detection Module - Header
 *
 * Handles foot strike detection and classification
 */

#ifndef GAIT_DETECTION_H
#define GAIT_DETECTION_H

#include <Arduino.h>
#include "config.h"

// Detect foot strike from acceleration data
bool detectFootStrike(float az);

// Classify strike type based on sensor data and pitch angle
StrikeType classifyStrike(float ax, float ay, float az, float pitch);

// Update stride state machine
void updateStrideState();

// Get current stride state
StrideState getStrideState();

// Reset gait detection (for testing/debugging)
void resetGaitDetection();

#endif // GAIT_DETECTION_H
