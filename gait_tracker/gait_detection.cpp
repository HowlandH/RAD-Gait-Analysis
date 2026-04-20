/*
 * Gait Detection Module - Implementation
 *
 * Handles foot strike detection and classification
 */

#include "gait_detection.h"
#include "imu_sensor.h"

// Global variables
StrideState currentState = SWING;
unsigned long lastStrikeTime = 0;
float peakAcceleration = 0.0;

bool detectFootStrike(float az) {
  unsigned long currentTime = millis();

  // Calculate magnitude of vertical acceleration
  float verticalAccel = abs(az);

  // Track peak acceleration during potential strike
  if (verticalAccel > peakAcceleration) {
    peakAcceleration = verticalAccel;
  }

  // Debounce: ignore strikes too close together
  if (currentTime - lastStrikeTime < STRIKE_DEBOUNCE) {
    return false;
  }

  static float lastAz = 0.0;

  // Detect strike when acceleration exceeds threshold
  if (verticalAccel > STRIKE_THRESHOLD) {
    // Confirm it's a peak (not just rising edge)
    // by checking if we're starting to decelerate
    if (verticalAccel < lastAz) { // Deceleration started - we passed the peak
      lastStrikeTime = currentTime;
      peakAcceleration = 0.0;
      lastAz = 0.0;

      if (DEBUG_MODE) {
        Serial.println(">>> Foot strike detected <<<");
      }

      return true;
    }
  }

  lastAz = verticalAccel;
  return false;
}

StrikeType classifyStrike(float ax, float ay, float az, float pitch) {
  // Classify based on pitch angle at moment of impact
  // Negative pitch = heel down (heel strike)
  // Near-zero pitch = flat foot (midfoot strike)
  // Positive pitch = toe down (forefoot strike)

  StrikeType type;

  if (pitch < HEEL_STRIKE_MAX) {
    type = HEEL;
  } else if (pitch > FOREFOOT_STRIKE_MIN) {
    type = FOREFOOT;
  } else {
    type = MIDFOOT;
  }

  if (DEBUG_MODE) {
    Serial.print("Strike classified as: ");
    Serial.print(type == HEEL ? "HEEL" : (type == MIDFOOT ? "MIDFOOT" : "FOREFOOT"));
    Serial.print(" (pitch: ");
    Serial.print(pitch, 1);
    Serial.println("°)");
  }

  return type;
}

void updateStrideState() {
  // Simple state machine for stride phases
  // This can be expanded for more sophisticated gait analysis

  switch (currentState) {
    case SWING:
      // Transition to STRIKE when foot strike is detected
      // (handled in detectFootStrike)
      break;

    case STRIKE:
      // Transition to STANCE after brief strike phase
      currentState = STANCE;
      break;

    case STANCE:
      // Transition to SWING when foot leaves ground
      // (detect by low vertical acceleration)
      // This is simplified - could use more sophisticated detection
      currentState = SWING;
      break;
  }
}

StrideState getStrideState() {
  return currentState;
}

void resetGaitDetection() {
  currentState = SWING;
  lastStrikeTime = 0;
  peakAcceleration = 0.0;
  Serial.println("Gait detection reset");
}
