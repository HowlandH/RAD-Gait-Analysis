/*
 * Stride Length Estimation Module - Header
 *
 * Calculates stride length using inverted pendulum model
 */

#ifndef STRIDE_LENGTH_H
#define STRIDE_LENGTH_H

#include <Arduino.h>

// Calculate stride length based on swing angle
float calculateStrideLength(float maxSwingAngle);

// Set user's leg length for calibration (in meters)
void setLegLength(float length);

// Get current leg length setting
float getLegLength();

// Set stride correction factor (for tuning accuracy)
void setStrideCorrectionFactor(float factor);

#endif // STRIDE_LENGTH_H
