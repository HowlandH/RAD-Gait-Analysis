/*
 * IMU Sensor Module - Header
 *
 * Handles MPU-6050 initialization, calibration, and data reading
 */

#ifndef IMU_SENSOR_H
#define IMU_SENSOR_H

#include <Arduino.h>

// Initialize the MPU-6050 sensor
void initIMU();

// Calibrate the IMU (must be on flat surface)
void calibrateIMU();

// Read raw accelerometer and gyroscope data
void readIMUData(float &ax, float &ay, float &az, float &gx, float &gy, float &gz);

// Update orientation estimation using sensor fusion
void updateOrientation();

// Get current pitch angle (degrees)
float getPitchAngle();

// Get current roll angle (degrees)
float getRollAngle();

// Get maximum swing angle detected during current stride
float getMaxSwingAngle();

// Reset swing angle tracking (called at foot strike)
void resetSwingAngle();

// Check if device is stationary (for power management)
bool isStationary();

// Get time since last significant motion (ms)
unsigned long getTimeSinceLastMotion();

#endif // IMU_SENSOR_H
