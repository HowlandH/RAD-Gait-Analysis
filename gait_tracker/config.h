/*
 * Gait Tracker - Configuration Header
 *
 * Central configuration file for all constants and settings
 */

#ifndef CONFIG_H
#define CONFIG_H

// ===== Hardware Configuration =====
#define MPU6050_ADDRESS 0x68  // I2C address of MPU-6050
#define SDA_PIN A4            // I2C SDA pin
#define SCL_PIN A5            // I2C SCL pin

// ===== Timing Configuration =====
#define IMU_READ_INTERVAL 10           // Read IMU every 10ms (100Hz)
#define CADENCE_UPDATE_INTERVAL 1000   // Update cadence every 1 second
#define BATTERY_UPDATE_INTERVAL 30000  // Update battery every 30 seconds
#define IDLE_TIMEOUT 30000             // Enter low power after 30s of inactivity

// ===== IMU Configuration =====
#define ACCEL_RANGE 2       // Accelerometer range: ±2g
#define GYRO_RANGE 250      // Gyroscope range: ±250°/s
#define GRAVITY 9.81        // Gravity constant (m/s²)

// Complementary filter coefficient (0.0 - 1.0)
// Higher value = trust gyroscope more, lower value = trust accelerometer more
#define ALPHA 0.96

// ===== Gait Detection Configuration =====
// Foot strike detection threshold (in g's)
#define STRIKE_THRESHOLD 2.0

// Debounce time to ignore secondary peaks (ms)
#define STRIKE_DEBOUNCE 200

// Strike classification pitch angle thresholds (degrees)
#define HEEL_STRIKE_MAX -15.0    // Pitch < -15° = heel strike
#define FOREFOOT_STRIKE_MIN 5.0  // Pitch > +5° = forefoot strike
// Between these values = midfoot strike

// ===== Stride Length Configuration =====
// Default leg length (hip to ground) in meters
// User can calibrate this via iOS app
#define DEFAULT_LEG_LENGTH 0.90

// Stride length correction factor (tune based on field testing)
#define STRIDE_CORRECTION_FACTOR 1.0

// ===== Cadence Configuration =====
// Number of recent foot strikes to track for cadence calculation
#define CADENCE_BUFFER_SIZE 30

// Minimum strikes needed before calculating cadence
#define MIN_STRIKES_FOR_CADENCE 3

// ===== BLE Configuration =====
// Device name (visible during scanning)
#define BLE_DEVICE_NAME "GaitTracker"

// BLE Service UUIDs (custom UUIDs - generate your own if needed)
#define GAIT_SERVICE_UUID "19b10000-e8f2-537e-4f6c-d104768a1214"

// BLE Characteristic UUIDs
#define STRIDE_LENGTH_CHAR_UUID "19b10001-e8f2-537e-4f6c-d104768a1214"
#define CADENCE_CHAR_UUID       "19b10002-e8f2-537e-4f6c-d104768a1214"
#define STRIKE_TYPE_CHAR_UUID   "19b10003-e8f2-537e-4f6c-d104768a1214"
#define BATTERY_CHAR_UUID       "00002a19-0000-1000-8000-00805f9b34fb"  // Standard Battery Level

// BLE connection interval (ms)
#define BLE_CONNECTION_INTERVAL 15

// ===== Power Management Configuration =====
// Battery voltage divider ratio (adjust based on your circuit)
// If using 2x 10kΩ resistors: ratio = 0.5
#define BATTERY_VOLTAGE_RATIO 0.5

// Battery voltage range (3.0V empty, 4.2V full)
#define BATTERY_EMPTY_VOLTAGE 3.0
#define BATTERY_FULL_VOLTAGE 4.2

// Analog pin for battery voltage reading
#define BATTERY_PIN A0

// ===== Debug Configuration =====
// Set to true to enable verbose serial debug output
#define DEBUG_MODE true

// Set to true to enable IMU data streaming over BLE (for debugging)
#define ENABLE_IMU_STREAM false

// ===== Data Types =====
// Strike type enumeration
enum StrikeType {
  HEEL = 0,
  MIDFOOT = 1,
  FOREFOOT = 2
};

// Stride state machine
enum StrideState {
  SWING,
  STRIKE,
  STANCE
};

#endif // CONFIG_H
