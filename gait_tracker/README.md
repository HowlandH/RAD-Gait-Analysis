# Gait Tracker - Arduino Firmware

Arduino firmware for the running gait analysis device.

## Hardware Requirements

- Arduino Nano 33 BLE Rev2
- MPU-6050 6-axis IMU
- MP2636 Power Booster & Charger Module
- 3.7V 700mAh LiPo Battery

## Wiring

```
MPU-6050 → Arduino Nano 33 BLE Rev2
  VCC → 3.3V
  GND → GND
  SCL → A5 (SCL)
  SDA → A4 (SDA)

MP2636 Power Module → Arduino Nano
  5V OUT → VIN
  GND → GND

LiPo Battery → MP2636
  + → BAT+
  - → BAT-
```

## Required Libraries

Install these libraries via Arduino Library Manager:

1. **ArduinoBLE** - For Bluetooth Low Energy communication
2. **Adafruit MPU6050** - For IMU sensor interface
3. **Adafruit Sensor** - Dependency for MPU6050 library
4. **Wire** - I2C communication (built-in)

## Installation

1. Open `gait_tracker.ino` in Arduino IDE
2. Select board: **Arduino Nano 33 BLE** (Tools → Board)
3. Install required libraries
4. Uncomment library includes in relevant files:
   - `imu_sensor.cpp` - MPU6050 library
   - `ble_comms.cpp` - ArduinoBLE library
5. Upload to board

## Configuration

Edit `config.h` to adjust:

- Strike detection threshold
- Cadence buffer size
- BLE service UUIDs
- Battery voltage divider ratio
- Debug mode settings

## Module Overview

### imu_sensor.h/cpp
- Initializes MPU-6050
- Reads accelerometer and gyroscope at 100Hz
- Applies complementary filter for orientation
- Tracks pitch/roll angles and swing angle

### gait_detection.h/cpp
- Detects foot strikes via Z-axis acceleration peaks
- Classifies strike type (heel/midfoot/forefoot) based on pitch angle
- Implements stride state machine

### stride_length.h/cpp
- Estimates stride length using inverted pendulum model
- Formula: `stride_length = 4 * h * sin(θ/2)`
- Supports leg length calibration

### cadence.h/cpp
- Tracks steps per minute using circular buffer
- Maintains rolling average over last 30 strikes
- Target accuracy: ±3 steps/min

### ble_comms.h/cpp
- Advertises as "GaitTracker"
- Implements GATT characteristics for metrics
- Handles connection/disconnection events

### power_mgmt.h/cpp
- Monitors battery voltage via analog pin
- Calculates battery percentage
- Supports low-power mode (TODO)

## Testing

### I2C Scanner Test
Run I2C scanner sketch to verify MPU-6050 at address `0x68`

### Serial Monitor
Set baud rate to **115200** for debug output

### Desktop Testing
1. Tap device on desk at known cadence (use metronome app)
2. Verify strike detection in serial output
3. Tilt device during taps to test strike classification

### BLE Testing
Use "nRF Connect" iOS app to:
- Scan for "GaitTracker" device
- Connect and view characteristics
- Subscribe to notifications

## Calibration

1. Place device on flat surface
2. Power on - calibration runs automatically
3. Verify serial output shows gyroscope offsets
4. Expected accelerometer: Z ≈ 1g, X/Y ≈ 0g

## Troubleshooting

**MPU-6050 not detected:**
- Check I2C wiring (SDA/SCL)
- Run I2C scanner sketch
- Verify 3.3V power connection

**BLE not advertising:**
- Ensure ArduinoBLE library is installed
- Check Serial Monitor for error messages
- Verify board is Arduino Nano 33 BLE Rev2

**Inaccurate strike detection:**
- Adjust `STRIKE_THRESHOLD` in config.h
- Check IMU mounting orientation
- Verify device is secured to shoe

## Next Steps

1. Complete Phase 1: Hardware verification
2. Install required libraries and uncomment includes
3. Test with breadboard setup
4. Proceed to field testing once stable
