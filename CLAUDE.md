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

## Hardware Architecture

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

| File | Responsibility |
|------|---------------|
| `gait_tracker.ino` | Main loop at 100Hz; orchestrates all modules |
| `config.h` | All constants and enum definitions |
| `imu_sensor.h/.cpp` | MPU-6050 init, calibration, complementary filter, pitch tracking |
| `gait_detection.h/.cpp` | Foot strike peak detection and heel/midfoot/forefoot classification |
| `stride_length.h/.cpp` | Inverted pendulum stride estimation |
| `cadence.h/.cpp` | Circular buffer cadence calculation |
| `ble_comms.h/.cpp` | ArduinoBLE GATT service and characteristic updates |
| `power_mgmt.h/.cpp` | Battery voltage monitoring (low-power mode disabled) |

### Key Configuration Values (`config.h`)

```cpp
STRIKE_THRESHOLD    1.5      // g's
STRIKE_DEBOUNCE     200      // ms between strikes
HEEL_STRIKE_MAX    -15.0     // pitch degrees
FOREFOOT_STRIKE_MIN  5.0     // pitch degrees
DEFAULT_LEG_LENGTH   0.90    // meters
ALPHA               0.96     // complementary filter (gyro weight)
DEBUG_MODE          false    // set true for serial pitch/swing output
ENABLE_IMU_STREAM   false    // set true for raw accelerometer streaming
```

### Algorithms

**Strike detection:** Peak detection on Z-axis acceleration. `detectFootStrike()` uses a `static float lastAz` declared *outside* the threshold block to confirm deceleration after crossing `STRIKE_THRESHOLD`. Debounce prevents double-counting.

**Strike classification:** Pitch angle at moment of impact — heel (<-15°), midfoot (-15° to +5°), forefoot (>+5°).

**Stride length:** Inverted pendulum model: `stride = 4 * legLength * sin(θ/2)`. Swing angle tracked as `abs(pitch)` peak during swing phase. Critical ordering: `resetSwingAngle()` must be called *after* `calculateStrideLength()` in `gait_tracker.ino` — calling it before produces zero stride output.

**Cadence:** Circular buffer of strike timestamps. Requires `MIN_STRIKES_FOR_CADENCE` (3) before reporting.

### BLE UUIDs

```
Service:     19b10000-e8f2-537e-4f6c-d104768a1214
Stride:      19b10001-e8f2-537e-4f6c-d104768a1214  (Float, 4 bytes)
Cadence:     19b10002-e8f2-537e-4f6c-d104768a1214  (UInt16, 2 bytes)
Strike type: 19b10003-e8f2-537e-4f6c-d104768a1214  (UInt8: 0=Heel,1=Mid,2=Fore)
Battery:     00002a19-0000-1000-8000-00805f9b34fb   (UInt8, standard)
```

### Arduino IDE Setup

1. Board: Arduino Nano 33 BLE (not "Rev2" — same package in IDE)
2. Required libraries: `ArduinoBLE`, `Adafruit MPU6050`, `Adafruit Unified Sensor`
3. Serial monitor: 115200 baud
4. Expected upload: ~36% program storage, ~27% RAM

**Low-power mode** is commented out in `gait_tracker.ino` — do not re-enable without explicit instruction.

## iOS App Architecture (`GaitTrackerX/`)

### Project Structure

- Active Xcode project: `GaitTrackerX/GaitTrackerX.xcodeproj`
- Source files: `GaitTrackerX/GaitTrackerX/GaitTracker/`
- The project uses `PBXFileSystemSynchronizedRootGroup` — Xcode auto-includes **every** `.swift` file in the folder. Adding a file to the filesystem is enough; no need to manually add to the project.
- `GaitTrackerXApp.swift` is a **stub with no code** — the real entry point is `GaitTracker/GaitTrackerApp.swift`
- `GaitTracker/` at the repo root is an older copy of the source files, not used by the Xcode build
- Bundle identifier: `com.hudsonhowland.GaitTrackerX`

### Platform Targets

The project targets **iOS, macOS, and visionOS simultaneously** (`IPHONEOS_DEPLOYMENT_TARGET = 26.2`). This means:
- Do NOT use `Color(.systemBackground)` or `Color(.systemGroupedBackground)` — use `.background` (SwiftUI `BackgroundStyle`) instead
- Do NOT use `.navigationBarTrailing` / `.navigationBarLeading` — use `.automatic`
- Do NOT use `UIKit` types directly — use SwiftUI equivalents (e.g. `ShareLink` instead of `UIActivityViewController`)
- The project uses `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` and `SWIFT_APPROACHABLE_CONCURRENCY = YES` — all code is implicitly `@MainActor`

### Key Files

| File | Responsibility |
|------|---------------|
| `GaitTrackerApp.swift` | `@main` entry; injects `BLEManager` and `DataManager` as environment objects |
| `BLEManager.swift` | `CBCentralManager`/`CBPeripheral` delegate; scans, connects, parses all four BLE characteristics |
| `DataManager.swift` | Persists `[RunRecord]` via `UserDefaults` + `JSONEncoder`; `delete(at:)`, `deleteAll()`, `exportCSV()` |
| `RunSession.swift` | Active run timer, step accumulation, dominant strike calculation; `stop()` returns a `RunRecord` |
| `GaitMetrics.swift` | `StrikeType` enum (UInt8 raw), `GaitMetrics` struct, `RunRecord` (Identifiable + Codable) |
| `ConnectionView.swift` | BLE scanning UI with animated pulse rings |
| `DashboardView.swift` | Live metrics: cadence hero card (gradient changes color by performance), stride, strike, distance, time, pace; run start/pause/stop controls |
| `HistoryView.swift` | Run history cards + Charts framework: cadence trend (bar), distance (bar), strike distribution (donut) — shown when 2+ runs exist |
| `SettingsView.swift` | Leg length slider (0.6–1.1m), imperial toggle, haptic toggle, cadence/strike guides, delete all history |

### Data Flow

```
Arduino firmware
  → BLE notify → BLEManager.metrics (@Published GaitMetrics)
  → DashboardView reads bleManager.metrics live
  → onChange(of: bleManager.metrics.stepCount) { _, _ in }  ← two-arg form required (iOS 17+)
  → session.updateMetrics() during active run
  → session.stop() → RunRecord → dataManager.save()
  → DataManager persists to UserDefaults
  → HistoryView reads dataManager.runHistory
```

### BLE Parsing

`peripheral(_:didUpdateValueFor:)` in `BLEManager` updates properties directly (no `DispatchQueue.main.async` needed — `queue: nil` delivers on main, class is `@MainActor`):
```swift
Float   ← stride length (4 bytes)
UInt16  ← cadence (2 bytes)
UInt8   ← strike type (1 byte)
UInt8   ← battery level (1 byte)
```

## Development Status

**Firmware:** Fully functional and verified on hardware. Strike detection, classification, cadence, and stride length all working.

**iOS App:** Building and running on physical iPhone. All known build errors resolved.

**Field testing:** Not yet completed. Pending: real walking/running test, cadence accuracy vs metronome, stride length vs measured distance, battery life measurement.

## Testing

**Desktop:** Tap device on desk to trigger strike detection. Serial monitor at 115200 baud. Use nRF Connect (iOS app) to verify BLE characteristics independently of the iOS app.

**Field test targets:**
- Cadence: ±3 steps/min vs metronome or GPS watch
- Stride length: ±5% vs measured distance
- Strike classification: >80% agreement with video analysis
- Battery: ≥3 hours continuous
