/*
 * Cadence Calculation Module - Implementation
 *
 * Tracks steps per minute using circular buffer
 */

#include "cadence.h"
#include "config.h"

// Circular buffer for foot strike timestamps
unsigned long strikeTimestamps[CADENCE_BUFFER_SIZE];
int strikeBufferIndex = 0;
int strikeCount = 0;
unsigned long totalSteps = 0;

void incrementStepCount() {
  // Record timestamp
  unsigned long currentTime = millis();
  strikeTimestamps[strikeBufferIndex] = currentTime;

  // Move to next buffer position (circular)
  strikeBufferIndex = (strikeBufferIndex + 1) % CADENCE_BUFFER_SIZE;

  // Track total strikes
  if (strikeCount < CADENCE_BUFFER_SIZE) {
    strikeCount++;
  }

  totalSteps++;

  if (DEBUG_MODE) {
    Serial.print("Step count: ");
    Serial.println(totalSteps);
  }
}

float calculateCadence() {
  // Need at least 3 strikes to calculate cadence
  if (strikeCount < MIN_STRIKES_FOR_CADENCE) {
    return 0.0;
  }

  // Find oldest and newest timestamps in buffer
  int oldestIndex = (strikeBufferIndex - strikeCount + CADENCE_BUFFER_SIZE) % CADENCE_BUFFER_SIZE;
  int newestIndex = (strikeBufferIndex - 1 + CADENCE_BUFFER_SIZE) % CADENCE_BUFFER_SIZE;

  unsigned long oldestTime = strikeTimestamps[oldestIndex];
  unsigned long newestTime = strikeTimestamps[newestIndex];

  // Calculate time span in minutes
  float timeSpanMinutes = (newestTime - oldestTime) / 60000.0;

  // Avoid division by zero
  if (timeSpanMinutes < 0.01) {
    return 0.0;
  }

  // Calculate cadence: steps per minute
  // We have (strikeCount - 1) intervals between strikeCount strikes
  float cadence = (strikeCount - 1) / timeSpanMinutes;

  if (DEBUG_MODE) {
    // Uncomment for detailed debugging
    // Serial.print("Cadence calculation - Strikes: ");
    // Serial.print(strikeCount);
    // Serial.print(" | Time span: ");
    // Serial.print(timeSpanMinutes, 2);
    // Serial.print(" min | Cadence: ");
    // Serial.println(cadence, 1);
  }

  return cadence;
}

unsigned long getTotalStepCount() {
  return totalSteps;
}

void resetCadence() {
  strikeBufferIndex = 0;
  strikeCount = 0;
  totalSteps = 0;

  // Clear buffer
  for (int i = 0; i < CADENCE_BUFFER_SIZE; i++) {
    strikeTimestamps[i] = 0;
  }

  Serial.println("Cadence tracking reset");
}
