# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed - 2026-01-14

#### Breadboard Layout Documentation Updates

Updated [docs/breadboard_layout.md](docs/breadboard_layout.md) to reflect accurate component specifications based on datasheet review:

**MP2636 Power Module Pin Labels:**
- Changed "5V OUT" to "VOUT" throughout documentation to match actual DFRobot DFR0446 breakout board pin labels
- Updated visual diagram (line 45)
- Updated connection instructions (line 105)
- Updated wiring summary table (line 142)
- Updated troubleshooting section (line 258)

**MP2636 USB Connector Clarification:**
- Corrected USB connector types based on DFRobot DFR0446 specifications
- Changed "USB-C IN" to "Micro-USB IN" for charging input (line 43)
- Added "USB-A OUT" as 5V output port (line 44)
- Clarified that USB-A is an output port (alternative to VOUT pin), not for charging (line 130)
- Updated charging instructions to specify Micro-USB only (line 128)
- Updated troubleshooting to reference correct USB ports (line 263, 265)

**Battery Wiring Diagram Fix:**
- Corrected visual diagram to accurately show battery has only 2 wires (lines 36-59)
- Fixed confusing diagram that made it appear battery negative had multiple connections
- Clarified that battery RED(+) connects to MP2636 BAT+ and battery BLACK(-) connects to MP2636 BAT-
- Common ground is established via separate jumper wire from MP2636 GND to Arduino GND (BROWN wire)
- Added note in diagram showing battery minus connection path to BAT- pin

**Rationale:**
- Review of component datasheets (Arduino Nano 33 BLE Rev2, MPU-6050, MP2636) confirmed most connections were correct
- DFRobot DFR0446 module uses "VOUT" label (connected to MP2636 IC's SYS pin) instead of generic "5V OUT"
- Module features both Micro-USB input (for charging) and USB-A output (5V out, power bank style)
- All other connections (MPU-6050 to Arduino, battery connections) verified as correct

### References
- DFRobot MP2636 Product Page: https://www.dfrobot.com/product-1613.html
- Component datasheets reviewed in `/Scratch` directory

---

### Changed - 2026-02-23

#### Firmware Activation and Bug Fixes

**imu_sensor.cpp - Activated real library code:**
- Uncommented Adafruit MPU6050 and Adafruit Sensor library includes
- Activated real `initIMU()` with proper error handling and sensor configuration
- Activated real `calibrateIMU()` with 100-sample gyroscope offset averaging
- Activated real `readIMUData()` with unit conversions (m/s² to g's, rad/s to deg/s)
- Fixed swing angle tracking - changed from `gz * dt` (near-zero per sample) to `abs(pitch)` (accumulated angle)
- Added periodic debug output for pitch and maxSwingAngle values

**ble_comms.cpp - Activated real library code:**
- Uncommented ArduinoBLE library include
- Activated BLE service and all four characteristics (stride, cadence, strike type, battery)
- Activated `initBLE()`, connection handling, and all characteristic update functions

**gait_detection.cpp - Bug fixes:**
- Fixed peak detection logic - moved `lastAz` declaration outside threshold block so deceleration is correctly detected
- Removed premature `resetSwingAngle()` call from inside `detectFootStrike()` to prevent clearing angle before stride calculation

**gait_tracker.ino - Bug fixes:**
- Added IMU streaming debug output (controlled by `ENABLE_IMU_STREAM` flag)
- Moved `resetSwingAngle()` to after `calculateStrideLength()` so swing angle is captured correctly

**config.h - Tuning:**
- Lowered `STRIKE_THRESHOLD` from 2.0g to 1.5g for better desk-tap detection during testing
- Added `ENABLE_IMU_STREAM` debug flag for raw accelerometer output
- Set `DEBUG_MODE` to false for clean production output

#### iOS App - Initial Implementation
Created complete SwiftUI iOS companion app in `GaitTracker/`:
- `GaitTrackerApp.swift` - App entry point with tab navigation
- `Models/GaitMetrics.swift` - Data types for metrics and strike classification
- `Models/RunSession.swift` - Active run tracking with timer and step counting
- `Managers/BLEManager.swift` - CoreBluetooth wrapper matching Arduino firmware UUIDs
- `Managers/DataManager.swift` - Run history persistence via UserDefaults
- `Views/ConnectionView.swift` - BLE device scanning and pairing screen
- `Views/DashboardView.swift` - Live metrics display with run controls
- `Views/HistoryView.swift` - Past runs list with CSV export
- `Views/SettingsView.swift` - Leg length calibration and preferences

**iOS Bug Fixes:**
- Added `import Combine` to `DataManager.swift` to resolve `ObservableObject` conformance error
- Added `import Combine` to `RunSession.swift` for same reason
- Added `import UIKit` to `HistoryView.swift` for `UIActivityViewController` (share sheet)

#### Test Sketches
- Created `test_sketches/imu_ble_test/imu_ble_test.ino` - Combined IMU + BLE test sketch
- Verified MPU-6050 I2C communication at address 0x68
- Verified BLE advertising and connection via nRF Connect app
- Verified foot strike detection, cadence calculation, and stride length output
