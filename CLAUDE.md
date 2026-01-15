# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains a running gait tracker device that monitors stride length, foot strike patterns, and cadence. The system consists of:

1. **Arduino firmware** (C++) for Arduino Nano 33 BLE Rev2 + MPU-6050 IMU
2. **iOS companion app** (Swift/SwiftUI) for real-time data visualization
3. **3D CAD files** (Autodesk Inventor) for the enclosure design

**Design Specifications:**
- Total BOM < $60.00
- Cadence accuracy: ±3 steps/min
- Enclosure: ≤ 50mm × 40mm × 20mm
- Sampling rate: 100 Hz minimum
- Battery life: ≥3 hours
- Durability: 35-100°F, IPX3 moisture resistance

## Hardware Architecture

**Components:**
- Arduino Nano 33 BLE Rev2 (main controller with built-in BLE)
- MPU-6050 6-axis IMU (3-axis accelerometer + gyroscope) connected via I2C
- MP2636 power module managing 3.7V 700mAh LiPo battery
- 3D-printed PLA enclosure with rubber dampening

**Wiring:**
```
MPU-6050 → Arduino Nano 33 BLE Rev2
  VCC → 3.3V
  SCL → A5 (SCL)
  SDA → A4 (SDA)

MP2636 → Arduino VIN (5V) and GND
LiPo Battery → MP2636 BAT+ / BAT-
```

## Firmware Architecture

The Arduino firmware is organized into modular components:

### Core Modules

1. **IMU Data Acquisition** (`imu_sensor.h/.cpp`)
   - Initializes MPU-6050 at 100Hz sampling rate
   - Applies complementary/Kalman filter for orientation estimation
   - Calculates pitch angle from accelerometer + gyroscope fusion

2. **Gait Detection** (`gait_detection.h/.cpp`)
   - Detects foot strikes using Z-axis acceleration peak detection (>2g threshold)
   - Classifies strike type based on pitch angle at impact:
     - Heel: pitch < -15°
     - Midfoot: -15° to +5°
     - Forefoot: > +5°
   - Implements state machine: SWING → STRIKE → STANCE → SWING

3. **Stride Length Estimation** (`stride_length.h/.cpp`)
   - Uses inverted pendulum model: `stride_length = 4 * h * sin(θ/2)`
   - Integrates gyroscope during swing phase to find max swing angle
   - Requires leg length calibration from user

4. **Cadence Calculation** (`cadence.h/.cpp`)
   - Maintains circular buffer of foot strike timestamps
   - Formula: `cadence = (N-1) / (t_last - t_first) * 60`
   - Updates every second with rolling 30-second window

5. **BLE Communication** (`ble_comms.h/.cpp`)
   - Advertises as "GaitTracker"
   - GATT characteristics:
     - Stride Length: Float (4 bytes), notify
     - Cadence: Uint16 (2 bytes), notify
     - Foot Strike Type: Uint8 (1 byte), notify - 0=Heel, 1=Mid, 2=Forefoot
     - Battery Level: Uint8 (1 byte), notify - standard UUID 0x2A19
   - Sends updates every stride or every 1 second

6. **Power Management** (`power_mgmt.h/.cpp`)
   - Monitors battery via voltage divider (3.0V=0%, 4.2V=100%)
   - Enters low-power mode after 30 seconds of inactivity
   - Uses MPU-6050 motion interrupt for wake-up

### Main Loop Structure

The firmware runs at 100Hz with this pattern:
- Read IMU data every 10ms
- Detect foot strikes via peak detection
- Calculate metrics on each strike
- Update BLE characteristics
- Manage power state

## iOS App Architecture

**Technology Stack:**
- Swift + SwiftUI
- CoreBluetooth for BLE
- Core Data/CloudKit for persistence
- Minimum iOS 15.0

**Key Components:**

1. **BLEManager.swift** - Handles device scanning, connection, characteristic subscription
2. **GaitMetrics.swift** - Data models for stride length, cadence, strike type
3. **RunSession.swift** - Manages run start/stop, data aggregation, persistence
4. **ConnectionView.swift** - BLE scanning and pairing UI
5. **DashboardView.swift** - Real-time metrics display with color-coded strike indicators
6. **HistoryView.swift** - Past runs with graphs and statistics
7. **SettingsView.swift** - Leg length calibration, units, data export

## Development Workflow

### Arduino Firmware Development

**Setup:**
1. Install Arduino IDE
2. Add libraries: ArduinoBLE, MPU6050 (Adafruit or I2Cdevlib), Wire
3. Select board: Arduino Nano 33 BLE

**Testing:**
- Use I2C scanner to verify MPU-6050 at address 0x68
- Serial monitor at 115200 baud for debugging
- Use "nRF Connect" iOS app to test BLE characteristics

**Calibration:**
- Place device on flat surface
- Verify accelerometer: Z ≈ 1g, X/Y ≈ 0g
- Record gyroscope offsets for drift compensation

### iOS App Development

**Setup:**
1. Create SwiftUI project in Xcode
2. Add CoreBluetooth framework
3. Configure Info.plist for Bluetooth permissions

**Testing:**
- Test BLE connection with physical device
- Simulate foot strikes by tapping device on desk
- Validate data parsing from characteristics

### 3D Enclosure Design

**Autodesk Inventor workflow:**
1. Create parametric model with max dimensions: 50mm × 40mm × 20mm
2. Design snap-fit assembly with 0.2-0.3mm clearance
3. Include rubber dampening cavity for shock absorption
4. Export STL files for 3D printing

**3D Printing settings:**
- Material: PLA
- Layer height: 0.2mm
- Infill: 20-30%
- Estimated time: 2-3 hours

## Critical Algorithms

### Strike Classification Logic
Uses pitch angle at moment of impact (detected via Z-axis acceleration peak):
- Heel strike: Sharp acceleration peak + negative pitch (foot tilted back)
- Midfoot strike: Moderate peak + near-zero pitch (foot flat)
- Forefoot strike: Gradual peak + positive pitch (foot tilted forward)

### Stride Length Estimation
Inverted pendulum model is preferred over double integration to avoid drift:
- During swing phase, integrate gyroscope to find maximum swing angle
- Apply formula with user's leg length
- Use zero-velocity updates (ZUPT) when foot is on ground

### Cadence Accuracy Strategy
- Debounce foot strikes (ignore peaks within 200ms)
- Use circular buffer for rolling average
- Target: ±3 steps/min accuracy

## Testing Protocol

### Desktop Testing
1. Run I2C scanner to verify MPU-6050 detection
2. Tap device at known cadence using metronome app
3. Tilt device to different angles during taps to verify strike classification
4. Use nRF Connect to verify BLE characteristics update correctly

### Field Testing
1. **Treadmill:** Run at known pace, compare distance and cadence to display
2. **Track:** Run 1600m (4 laps × 400m), validate stride length calculation
3. **Video validation:** Record slow-motion video, manually count steps and classify strikes
4. **Battery test:** Full charge to depletion (target: ≥3 hours)
5. **Environmental:** Test 35-100°F range and light moisture

### Success Criteria
- Cadence: ±3 steps/min
- Stride length: ±5% over measured distance
- Strike classification: >80% agreement with video analysis
- Battery life: ≥3 hours continuous
- Connection: Stable for entire run without dropouts

## Known Technical Challenges

1. **Stride Length Drift:** Double integration causes drift. Use pendulum model + ZUPT instead.
2. **Strike Classification Variability:** Runners have different styles. Implement adaptive thresholds based on initial strides.
3. **Battery Drain:** 100Hz sampling is power-hungry. Use motion interrupts and reduce BLE transmission frequency.
4. **BLE Latency:** Notifications have variable delay. Buffer metrics and display moving averages in app.

## Important Notes

- **Do NOT use ESP32 or HC-05:** ESP32 is redundant (Arduino Nano has BLE), HC-05 is incompatible with iOS (requires BLE not Bluetooth Classic)
- **I2C address:** MPU-6050 should appear at 0x68
- **Sampling rate:** Must maintain 100Hz for accurate peak detection
- **Orientation:** MPU-6050 must align with foot's longitudinal axis in enclosure
- **Rubber dampening:** Critical for data integrity during 2.5-3.5× body weight impacts

## File Structure

```
Project Root/
├── initial.md                         # Complete implementation plan
├── gait_tracker/                      # Arduino firmware (to be created)
│   ├── gait_tracker.ino
│   ├── imu_sensor.h/cpp
│   ├── gait_detection.h/cpp
│   ├── stride_length.h/cpp
│   ├── cadence.h/cpp
│   ├── ble_comms.h/cpp
│   ├── power_mgmt.h/cpp
│   └── config.h
├── GaitTracker/                       # iOS app (to be created)
│   ├── GaitTrackerApp.swift
│   ├── Views/
│   ├── Models/
│   ├── Managers/
│   └── Resources/
└── enclosure/                         # 3D CAD files (to be created)
    ├── GaitTracker_Enclosure.ipt
    ├── case_top.stl
    ├── case_bottom.stl
    └── assembly.iam
```

## Current Development Phase

Project is in **PHASE 1: Hardware Setup & Verification**

Next steps:
1. Assemble breadboard with Arduino Nano + MPU-6050 + power module
2. Run I2C scanner to verify MPU-6050 detection
3. Test BLE advertising visibility
4. Measure baseline power consumption
5. Calibrate IMU on flat surface
