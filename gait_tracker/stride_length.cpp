/*
 * Stride Length Estimation Module - Implementation
 *
 * Calculates stride length using inverted pendulum model
 */

#include "stride_length.h"
#include "config.h"
#include <math.h>

// Global variables
float legLength = DEFAULT_LEG_LENGTH;
float strideCorrectionFactor = STRIDE_CORRECTION_FACTOR;

float calculateStrideLength(float maxSwingAngle) {
  // Inverted pendulum model:
  // stride_length = 4 * h * sin(θ/2)
  // where h = leg length, θ = maximum swing angle

  // Convert angle to radians
  float angleRadians = maxSwingAngle * PI / 180.0;

  // Calculate stride length
  float strideLength = 4.0 * legLength * sin(angleRadians / 2.0);

  // Apply correction factor (tuned from field testing)
  strideLength *= strideCorrectionFactor;

  if (DEBUG_MODE) {
    Serial.print("Stride calculation - Angle: ");
    Serial.print(maxSwingAngle, 2);
    Serial.print("° | Length: ");
    Serial.print(strideLength, 3);
    Serial.println(" m");
  }

  return strideLength;
}

void setLegLength(float length) {
  if (length > 0.3 && length < 1.5) { // Sanity check: 30cm to 150cm
    legLength = length;
    Serial.print("Leg length set to: ");
    Serial.print(legLength, 2);
    Serial.println(" m");
  } else {
    Serial.println("Invalid leg length. Must be between 0.3 and 1.5 meters");
  }
}

float getLegLength() {
  return legLength;
}

void setStrideCorrectionFactor(float factor) {
  if (factor > 0.5 && factor < 2.0) { // Sanity check
    strideCorrectionFactor = factor;
    Serial.print("Stride correction factor set to: ");
    Serial.println(strideCorrectionFactor, 2);
  } else {
    Serial.println("Invalid correction factor. Must be between 0.5 and 2.0");
  }
}
