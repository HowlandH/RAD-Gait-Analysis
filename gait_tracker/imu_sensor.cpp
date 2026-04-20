/*
 * IMU Sensor Module - Implementation
 *
 * Handles MPU-6050 initialization, calibration, and data reading
 */

#include "imu_sensor.h"
#include "config.h"
#include <Wire.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>

// Global variables
float pitch = 0.0;
float roll = 0.0;
float maxSwingAngle = 0.0;
float gyroOffsetX = 0.0;
float gyroOffsetY = 0.0;
float gyroOffsetZ = 0.0;

unsigned long lastUpdateTime = 0;
unsigned long lastMotionTime = 0;

Adafruit_MPU6050 mpu;

void initIMU() {
  // Initialize I2C
  Wire.begin();

  if (!mpu.begin(MPU6050_ADDRESS)) {
    Serial.println("Failed to find MPU6050 chip");
    while (1) {
      delay(10);
    }
  }
  Serial.println("MPU6050 Found!");

  // Set accelerometer range
  mpu.setAccelerometerRange(MPU6050_RANGE_2_G);

  // Set gyroscope range
  mpu.setGyroRange(MPU6050_RANGE_250_DEG);

  // Set filter bandwidth
  mpu.setFilterBandwidth(MPU6050_BAND_21_HZ);

  Serial.println("MPU6050 initialized successfully");

  lastUpdateTime = millis();
  lastMotionTime = millis();
}

void calibrateIMU() {
  Serial.println("Calibrating IMU... Keep device still on flat surface");

  const int numSamples = 100;
  float sumGX = 0, sumGY = 0, sumGZ = 0;

  for (int i = 0; i < numSamples; i++) {
    sensors_event_t a, g, temp;
    mpu.getEvent(&a, &g, &temp);

    sumGX += g.gyro.x;
    sumGY += g.gyro.y;
    sumGZ += g.gyro.z;

    delay(10);
  }

  gyroOffsetX = sumGX / numSamples;
  gyroOffsetY = sumGY / numSamples;
  gyroOffsetZ = sumGZ / numSamples;

  Serial.print("Gyro offsets - X: ");
  Serial.print(gyroOffsetX, 4);
  Serial.print(" Y: ");
  Serial.print(gyroOffsetY, 4);
  Serial.print(" Z: ");
  Serial.println(gyroOffsetZ, 4);

  Serial.println("Calibration complete");
}

void readIMUData(float &ax, float &ay, float &az, float &gx, float &gy, float &gz) {
  sensors_event_t accel, gyro, temp;
  mpu.getEvent(&accel, &gyro, &temp);

  // Convert to appropriate units
  ax = accel.acceleration.x / GRAVITY;  // Convert to g's
  ay = accel.acceleration.y / GRAVITY;
  az = accel.acceleration.z / GRAVITY;

  // Apply gyro offsets and convert to degrees/sec
  gx = (gyro.gyro.x - gyroOffsetX) * 57.2958; // rad/s to deg/s
  gy = (gyro.gyro.y - gyroOffsetY) * 57.2958;
  gz = (gyro.gyro.z - gyroOffsetZ) * 57.2958;
}

void updateOrientation() {
  unsigned long currentTime = millis();
  float dt = (currentTime - lastUpdateTime) / 1000.0; // Convert to seconds
  lastUpdateTime = currentTime;

  // Get current sensor data
  float ax, ay, az, gx, gy, gz;
  readIMUData(ax, ay, az, gx, gy, gz);

  // Calculate pitch and roll from accelerometer
  float accelPitch = atan2(ay, sqrt(ax * ax + az * az)) * 57.2958;
  float accelRoll = atan2(-ax, az) * 57.2958;

  // Integrate gyroscope for pitch and roll
  pitch += gy * dt;
  roll += gx * dt;

  // Apply complementary filter
  pitch = ALPHA * pitch + (1.0 - ALPHA) * accelPitch;
  roll = ALPHA * roll + (1.0 - ALPHA) * accelRoll;

  // Track maximum swing angle during stride using absolute pitch angle
  float currentSwingAngle = abs(pitch);
  if (currentSwingAngle > maxSwingAngle) {
    maxSwingAngle = currentSwingAngle;
  }

  // Update motion detection
  float totalAccel = sqrt(ax * ax + ay * ay + az * az);
  if (abs(totalAccel - 1.0) > 0.1) { // More than 0.1g deviation from stationary
    lastMotionTime = currentTime;
  }

  if (DEBUG_MODE) {
    static int debugCounter = 0;
    if (++debugCounter >= 20) { // Print every 20 reads = every 200ms
      debugCounter = 0;
      Serial.print("Pitch: "); Serial.print(pitch, 1);
      Serial.print("° | MaxSwing: "); Serial.print(maxSwingAngle, 1);
      Serial.println("°");
    }
  }
}

float getPitchAngle() {
  return pitch;
}

float getRollAngle() {
  return roll;
}

float getMaxSwingAngle() {
  return maxSwingAngle;
}

void resetSwingAngle() {
  maxSwingAngle = 0.0;
}

bool isStationary() {
  return (millis() - lastMotionTime) > 5000; // Stationary if no motion for 5 seconds
}

unsigned long getTimeSinceLastMotion() {
  return millis() - lastMotionTime;
}
