/*
 * Cadence Calculation Module - Header
 *
 * Tracks steps per minute using circular buffer
 */

#ifndef CADENCE_H
#define CADENCE_H

#include <Arduino.h>

// Increment step count (call when foot strike detected)
void incrementStepCount();

// Calculate current cadence (steps per minute)
float calculateCadence();

// Get total step count
unsigned long getTotalStepCount();

// Reset cadence tracking (for new run)
void resetCadence();

#endif // CADENCE_H
