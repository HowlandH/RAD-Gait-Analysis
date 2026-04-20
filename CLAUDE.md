# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## User Preferences

- **Never use emojis** in any documentation, code files, or communication

## Project Overview

Running gait tracker: a foot-mounted device that monitors stride length, foot strike patterns, and cadence. The system consists of:

1. **Arduino firmware** (`gait_tracker/`) - C++ for Arduino Nano 33 BLE Rev2 + MPU-6050 IMU
2. **iOS companion app** (`GaitTrackerX/`) - Swift/SwiftUI, active Xcode project
3. **3D CAD files** (`cad/`) - OpenSCAD model + Autodesk Inventor specifications

**Design Specifications:**
- Total BOM < $60.00
- Cadence accuracy: ±3 steps/min
- Enclosure: ≤ 50mm × 40mm × 20mm
- Sampling rate: 100 Hz
- Battery life: ≥ 3 hours
- Durability: 35-100°F, IPX3 moisture resistance

## Hardware Architecture

**Components:**
- Arduino Nano 33 BLE Rev2 (ARM Cortex-M4, built-in BLE)
- MPU-6050 6-axis IMU via I2C
- DFRobot MP2636 (DFR0446) power module with 3.7V 700mAh LiPo battery

**Wiring:**
```
MPU-6050 → Arduino Nano 33 BLE Rev2
  VCC → 3.3V
  GND → GND
  SCL → A5
  SDA → A4

MP2636 (DFR0446)
  VOUT → Arduino VIN  (5V regulated output from SYS pin)
  GND  → Arduino GND
  BAT+ → LiPo red wire
  BAT- → LiPo black wire
  Micro-USB port = charging input only
  USB-A port = 5V output (alternative to VOUT pin)
```

See `docs/breadboard_layout.md` for full wiring diagrams.

## Firmware Architecture (`gait_tracker/`)

### Module Overview

| File | Responsibility |
|------|---------------|
| `gait_tracker.ino` | Main loop at 100Hz; orchestrates all modules |
| `config.h` | All constants and enum definitions |
| `imu_sensor.h/.cpp` | MPU-6050 init, calibration, complementary filter, pitch tracking |
| `gait_detection.h/.cpp` | Foot strike peak detection and heel/midfoot/forefoot classification |
| `stride_length.h/.cpp` | Inverted pendulum stride estimation |
| `cadence.h/.cpp` | Circular buffer cadence calculation |
| `ble_comms.h/.cpp` | ArduinoBLE GATT service and characteristic updates |
| `power_mgmt.h/.cpp` | Battery voltage monitoring (low-power mode disabled for now) |

### Key Configuration Values (`config.h`)

```cpp
STRIKE_THRESHOLD   1.5      // g's; lower for desk-tap testing
STRIKE_DEBOUNCE    200      // ms between strikes
HEEL_STRIKE_MAX    -15.0    // pitch degrees
FOREFOOT_STRIKE_MIN 5.0     // pitch degrees
DEFAULT_LEG_LENGTH  0.90    // meters
ALPHA              0.96     // complementary filter (gyro weight)
DEBUG_MODE         false
ENABLE_IMU_STREAM  false
```

### Algorithms

**Strike detection:** Peak detection on Z-axis acceleration. `detectFootStrike()` uses a `static float lastAz` to confirm deceleration after crossing `STRIKE_THRESHOLD`. Debounce prevents double-counting.

**Strike classification:** Pitch angle at moment of impact — heel (<-15°), midfoot (-15° to +5°), forefoot (>+5°).

**Stride length:** Inverted pendulum model: `stride = 4 * legLength * sin(θ/2)`. Swing angle is tracked as `abs(pitch)` peak during swing phase (not gyro integration). `resetSwingAngle()` is called *after* `calculateStrideLength()` in `gait_tracker.ino`.

**Cadence:** Circular buffer of strike timestamps. Formula: `(N-1) / (t_last - t_first) * 60`. Requires `MIN_STRIKES_FOR_CADENCE` (3) before reporting.

### BLE UUIDs

```
Service:    19b10000-e8f2-537e-4f6c-d104768a1214
Stride:     19b10001-e8f2-537e-4f6c-d104768a1214  (Float, 4 bytes)
Cadence:    19b10002-e8f2-537e-4f6c-d104768a1214  (UInt16, 2 bytes)
Strike type:19b10003-e8f2-537e-4f6c-d104768a1214  (UInt8: 0=Heel,1=Mid,2=Fore)
Battery:    00002a19-0000-1000-8000-00805f9b34fb   (UInt8, standard)
```

### Arduino IDE Setup

1. Board: Arduino Nano 33 BLE (not "Rev2" — same package in IDE)
2. Required libraries: `ArduinoBLE`, `Adafruit MPU6050`, `Adafruit Unified Sensor`
3. Serial monitor: 115200 baud
4. Upload: Sketch → Upload (Ctrl+U / Cmd+U)

Verify upload success: ~36% program storage, ~27% RAM is expected.

## iOS App Architecture (`GaitTrackerX/`)

The active Xcode project is `GaitTrackerX/GaitTrackerX.xcodeproj`. Source files live under `GaitTrackerX/GaitTrackerX/GaitTracker/`.

The standalone `GaitTracker/` directory contains the original source files (before Xcode project was created) — these are mirrored into `GaitTrackerX/`. The `GaitTrackerXcode/` directory is an empty stub.

**Technology:** Swift + SwiftUI, CoreBluetooth, UserDefaults persistence, iOS 15.0+

**Key Components:**

- `BLEManager.swift` — `CBCentralManager`/`CBPeripheral` delegate; scans for "GaitTracker", subscribes to all four characteristics, publishes parsed values as `@Published` properties
- `DataManager.swift` — Persists `[RunRecord]` via `UserDefaults` + `JSONEncoder`; provides CSV export
- `RunSession.swift` — `ObservableObject` managing active run (timer, step counting, dominant strike type)
- `GaitMetrics.swift` — `StrikeType` enum, `GaitMetrics` struct, `RunRecord` (Identifiable + Codable)

**Views:** `ConnectionView` → `DashboardView` (live metrics + run controls) → `HistoryView` (past runs, CSV export) + `SettingsView` (leg length calibration 0.6–1.1m, units toggle)

### Known Xcode Issue

`RunRecord` may show an "ambiguous type" error if `RunSession.swift` was accidentally added to the Xcode project twice (creating duplicate type definitions). Fix: in Xcode's Project Navigator, find the duplicate `RunSession.swift` reference and **Remove Reference** (not Delete). The actual file on disk lives in `GaitTrackerX/GaitTrackerX/GaitTracker/Models/`.

## Development Status

**Firmware:** Fully functional. All modules activated. Strike detection, classification, cadence, and stride length verified working on hardware.

**iOS App:** All Swift source files written. Xcode project at `GaitTrackerX/GaitTrackerX.xcodeproj`. Build blocked by RunRecord ambiguous error (see above).

**Low-power mode:** Commented out in `gait_tracker.ino` — do not re-enable without explicit instruction.

## Testing

**Desktop (no shoe):** Tap device on desk to trigger strike detection. Serial monitor at 115200 baud shows detection events. Use nRF Connect (iOS app) to verify BLE characteristics update.

**Debug flags:** Set `DEBUG_MODE true` in `config.h` for verbose serial output including pitch angle and maxSwingAngle. Set `ENABLE_IMU_STREAM true` for raw accelerometer streaming.

**Field test targets:**
- Cadence: ±3 steps/min vs metronome
- Stride length: ±5% vs measured distance
- Strike classification: >80% agreement with video analysis
- Battery: ≥3 hours continuous
