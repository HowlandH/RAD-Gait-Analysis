/*
 * IMU + BLE Test Sketch
 *
 * Tests both MPU-6050 and BLE functionality together
 * Reads accelerometer data and broadcasts via BLE
 *
 * Hardware:
 * - Arduino Nano 33 BLE Rev2
 * - MPU-6050 connected via I2C (A4=SDA, A5=SCL)
 *
 * Libraries needed:
 * - ArduinoBLE
 * - Adafruit MPU6050
 * - Adafruit Unified Sensor
 */

#include <ArduinoBLE.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <Wire.h>

// Create MPU6050 object
Adafruit_MPU6050 mpu;

// BLE Service and Characteristics
BLEService imuService("180F"); // Using Battery Service UUID as placeholder
BLEFloatCharacteristic accelXChar("2A19", BLERead | BLENotify);
BLEFloatCharacteristic accelYChar("2A1A", BLERead | BLENotify);
BLEFloatCharacteristic accelZChar("2A1B", BLERead | BLENotify);

// Timing
unsigned long lastUpdate = 0;
const int updateInterval = 100; // 100ms = 10Hz

void setup() {
  Serial.begin(115200);
  while (!Serial && millis() < 3000); // Wait up to 3 seconds for Serial

  Serial.println("=== IMU + BLE Test ===");
  Serial.println();

  // Initialize MPU6050
  Serial.print("Initializing MPU6050... ");
  if (!mpu.begin()) {
    Serial.println("FAILED!");
    Serial.println("Could not find MPU6050 sensor!");
    Serial.println("Check wiring:");
    Serial.println("  VCC -> 3.3V");
    Serial.println("  GND -> GND");
    Serial.println("  SDA -> A4");
    Serial.println("  SCL -> A5");
    while (1) {
      delay(1000);
    }
  }
  Serial.println("OK");

  // Configure MPU6050
  mpu.setAccelerometerRange(MPU6050_RANGE_8_G);
  mpu.setGyroRange(MPU6050_RANGE_500_DEG);
  mpu.setFilterBandwidth(MPU6050_BAND_21_HZ);

  Serial.println("MPU6050 configured:");
  Serial.println("  Accelerometer range: ±8G");
  Serial.println("  Gyroscope range: ±500°/s");
  Serial.println("  Filter bandwidth: 21 Hz");
  Serial.println();

  // Initialize BLE
  Serial.print("Initializing BLE... ");
  if (!BLE.begin()) {
    Serial.println("FAILED!");
    Serial.println("BLE initialization failed!");
    while (1) {
      delay(1000);
    }
  }
  Serial.println("OK");

  // Set BLE device name and advertised service
  BLE.setLocalName("GaitTest");
  BLE.setAdvertisedService(imuService);

  // Add characteristics to service
  imuService.addCharacteristic(accelXChar);
  imuService.addCharacteristic(accelYChar);
  imuService.addCharacteristic(accelZChar);

  // Add service
  BLE.addService(imuService);

  // Set initial values
  accelXChar.writeValue(0.0);
  accelYChar.writeValue(0.0);
  accelZChar.writeValue(0.0);

  // Start advertising
  BLE.advertise();

  Serial.println("BLE advertising started");
  Serial.println("Device name: GaitTest");
  Serial.println();
  Serial.println("Open nRF Connect app and look for 'GaitTest'");
  Serial.println();
  Serial.println("=== Starting Data Stream ===");
  Serial.println("Format: Accel [X, Y, Z] (m/s²)");
  Serial.println();
}

void loop() {
  // Listen for BLE connections
  BLEDevice central = BLE.central();

  // If connected, print connection info once
  if (central) {
    if (central.connected()) {
      static bool connectionPrinted = false;
      if (!connectionPrinted) {
        Serial.print("Connected to: ");
        Serial.println(central.address());
        connectionPrinted = true;
      }
    } else {
      Serial.println("Disconnected");
    }
  }

  // Read and broadcast sensor data at regular intervals
  if (millis() - lastUpdate >= updateInterval) {
    lastUpdate = millis();

    // Get sensor readings
    sensors_event_t accel, gyro, temp;
    mpu.getEvent(&accel, &gyro, &temp);

    // Print to Serial Monitor
    Serial.print("Accel [");
    Serial.print(accel.acceleration.x, 2);
    Serial.print(", ");
    Serial.print(accel.acceleration.y, 2);
    Serial.print(", ");
    Serial.print(accel.acceleration.z, 2);
    Serial.print("] m/s²  |  Gyro [");
    Serial.print(gyro.gyro.x, 2);
    Serial.print(", ");
    Serial.print(gyro.gyro.y, 2);
    Serial.print(", ");
    Serial.print(gyro.gyro.z, 2);
    Serial.print("] rad/s  |  Temp: ");
    Serial.print(temp.temperature, 1);
    Serial.println(" °C");

    // Update BLE characteristics
    accelXChar.writeValue(accel.acceleration.x);
    accelYChar.writeValue(accel.acceleration.y);
    accelZChar.writeValue(accel.acceleration.z);

    // Visual indicator for orientation (when flat on table)
    if (abs(accel.acceleration.z - 9.8) < 2.0) {
      // Z-axis pointing up (normal orientation)
    } else if (abs(accel.acceleration.z + 9.8) < 2.0) {
      Serial.println("  >>> UPSIDE DOWN <<<");
    }

    // Detect movement
    float totalAccel = sqrt(
      accel.acceleration.x * accel.acceleration.x +
      accel.acceleration.y * accel.acceleration.y +
      accel.acceleration.z * accel.acceleration.z
    );

    if (totalAccel > 15.0) {
      Serial.println("  >>> IMPACT DETECTED! <<<");
    }
  }
}
