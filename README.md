# RAD — Running Analysis Device

An affordable (<$60) foot-mounted wearable that tracks running gait metrics in real time and transmits data via Bluetooth Low Energy to an iOS companion app. Built for recreational runners and high school athletes who cannot access professional lab gait analysis ($350-500/session).

**Team:** Hudson Howland and Brantley Field — PLTW Engineering Capstone

---

## Project Status — COMPLETE

| Phase | Status |
|---|---|
| Hardware Assembly | COMPLETE |
| IMU Data Acquisition | COMPLETE |
| Gait Detection Firmware | COMPLETE |
| BLE Communication | COMPLETE |
| iOS Companion App | COMPLETE |
| Enclosure Design & Print | COMPLETE |
| System Integration | COMPLETE |
| Mounting Angle Calibration | COMPLETE |
| Field Testing | COMPLETE |
| Stakeholder Evaluation | COMPLETE |

---

## Hardware

| Component | Part | Cost |
|---|---|---|
| Microcontroller | Arduino Nano 33 BLE Rev2 | ~$25 |
| IMU Sensor | MPU-6050 (GY-521) | ~$3 |
| Power Module | DFRobot MP2636 | ~$10 |
| Battery | 3.7V 700mAh LiPo | ~$8 |
| Enclosure | 3D printed PLA | ~$2 |
| **Total BOM** | | **~$55** |

Enclosure dimensions: 50mm x 40mm x 20mm. Mounts to shoe laces via elastic strap. Snap-fit two-part design.

### Wiring

```
MPU-6050 → Arduino Nano 33 BLE Rev2
  VCC → 3.3V
  GND → GND
  SCL → A5
  SDA → A4

MP2636 Power Module
  VOUT (SYS pin) → Arduino VIN
  GND → Arduino GND
  BAT+ → LiPo red wire
  BAT- → LiPo black wire
  Micro-USB port = charging input only
```

---

## Firmware

Located in `gait_tracker/`. Written in C++ for Arduino Nano 33 BLE Rev2.

### Architecture

| File | Responsibility |
|---|---|
| `gait_tracker.ino` | Main 100Hz loop |
| `config.h` | All constants and thresholds |
| `imu_sensor.h/.cpp` | MPU-6050 init, complementary filter, pitch tracking, mounting angle calibration |
| `gait_detection.h/.cpp` | Foot strike peak detection and heel/midfoot/forefoot classification |
| `stride_length.h/.cpp` | Inverted pendulum stride estimation |
| `cadence.h/.cpp` | Circular buffer cadence calculation |
| `ble_comms.h/.cpp` | ArduinoBLE GATT service and characteristic updates |
| `power_mgmt.h/.cpp` | Battery voltage monitoring |

### Key Algorithms

**Strike detection:** Peak detection on Z-axis acceleration with 200ms debounce. Threshold: 1.5g.

**Strike classification:** Pitch angle at moment of impact:
- Heel: pitch < -15 degrees
- Midfoot: -15 to +5 degrees
- Forefoot: pitch > +5 degrees

**Mounting angle calibration:** On every boot, the firmware samples the device's resting pitch for 3 seconds while mounted on the shoe and stores it as an offset. All subsequent pitch readings subtract this offset so classification thresholds work correctly regardless of mounting angle or shoe geometry.

**Stride length:** Inverted pendulum model: `stride = 4 x legLength x sin(angle/2)`

**Cadence:** Circular buffer of last 30 strike timestamps. Requires 3 minimum strikes before reporting.

### BLE Characteristics

```
Service:     19b10000-e8f2-537e-4f6c-d104768a1214
Stride:      19b10001 (Float, 4 bytes)
Cadence:     19b10002 (UInt16, 2 bytes)
Strike type: 19b10003 (UInt8: 0=Heel, 1=Mid, 2=Fore)
Battery:     00002a19 (UInt8, standard)
```

### Setup

1. Install Arduino IDE
2. Install libraries: ArduinoBLE, Adafruit MPU6050, Adafruit Unified Sensor
3. Open `gait_tracker/gait_tracker.ino`
4. Select board: Arduino Nano 33 BLE
5. Upload — calibration runs automatically on boot

---

## iOS App (GaitTrackerX)

Located in `GaitTrackerX/`. Built in Swift/SwiftUI. Active Xcode project: `GaitTrackerX/GaitTrackerX.xcodeproj`.

### Screens

**Connection Screen** — scans for and connects to the Arduino device with animated BLE pulse rings.

**Live Dashboard** — cadence hero card with color feedback (red/orange/green/blue by performance zone), stride length, distance, duration, pace, and strike type displayed live. Start, pause, and stop run controls.

**Run History** — all past runs with bar charts for cadence trend and distance (last 7 runs) and a donut chart for overall strike type distribution.

**Run Detail** — full metrics for any past run including per-step strike distribution donut chart with counts and percentages, and a cadence analysis bar showing position on the 140-200 spm scale with the 170-180 optimal zone highlighted.

**Share Card** — generates a shareable PNG with dark navy/purple gradient design showing distance, cadence, steps, duration, and strike type.

**Settings** — leg length slider (affects stride calculation), imperial/metric toggle, delete history.

### Key Files

| File | Responsibility |
|---|---|
| `GaitTrackerApp.swift` | App entry point |
| `Managers/BLEManager.swift` | CoreBluetooth scanning, connection, characteristic parsing |
| `Managers/DataManager.swift` | Run history persistence via UserDefaults + JSONEncoder |
| `Models/RunSession.swift` | Active run timer and step accumulation |
| `Models/GaitMetrics.swift` | StrikeType enum and GaitMetrics struct |
| `Views/ConnectionView.swift` | BLE scanning UI |
| `Views/DashboardView.swift` | Live metrics and run controls |
| `Views/HistoryView.swift` | Run history and charts |
| `Views/RunDetailView.swift` | Per-run detailed metrics and graphs |
| `Views/RunSummaryCard.swift` | Shareable PNG card renderer |
| `Views/SettingsView.swift` | User preferences |

---

## Field Testing Results

**Test conducted:** Half-mile walk test, May 1, 2026

| Metric | Result |
|---|---|
| Distance recorded | 1.40 km (actual: 0.84 km, 67% overestimate) |
| Steps counted | 1,157 |
| Duration | 14:10 |
| Cadence | 74 spm |
| Strike classification | Nearly 100% forefoot (caused by mounting angle) |

**Issues identified and resolved:**

1. Forefoot classification bias — the device mounted at a forward angle on the shoe added a static pitch offset that pushed every strike above the +5 degree forefoot threshold. Fixed by adding automatic mounting angle calibration to the firmware startup routine.

2. Stride length overestimation — the inverted pendulum model is calibrated for running gait, not walking. The `STRIDE_CORRECTION_FACTOR` in `config.h` is set to 1.0 and should be tuned against measured track data at running pace.

---

## Stakeholder Evaluation

Feedback gathered from three evaluators:

**Jackson — Peer / Athlete :** Validated the core concept. Suggested adding padding to the enclosure and rounding the corners for comfort. Conditionally willing to use and recommend the device once accuracy is demonstrated.

**Trey — Software Engineer:** Called it an impressive first prototype. Approved of the real-time plus historical data display approach. Raised questions about data privacy and storage that were addressed: all data is stored locally on the user's iPhone with no cloud connection or external transmission.

**Diana — Competitive Runner / Junior Olympic Athlete:** Endorsed the concept for high school runners who cannot afford professional alternatives. Recommended moving to lace mounting over ankle mounting at race pace. Requested accuracy validation against a known device before full endorsement.

---

## Design Specifications

| Priority | Specification | Status |
|---|---|---|
| 1 (Cost) | BOM under $60 | MET — ~$55 |
| 2 (Functionality) | Cadence within 3 spm accuracy | Pending running field test |
| 3 (Size) | Enclosure max 50x40x20mm | MET |
| 4 (Data Rate) | Minimum 100Hz sampling | MET |
| 5 (Battery) | Minimum 3 hours continuous | Pending test |
| 6 (Durability) | IPX3 moisture resistance | Pending test |

---

## Repository Structure

```
RAD-Gait-Analysis/
├── gait_tracker/              # Arduino firmware (active)
│   ├── gait_tracker.ino
│   ├── config.h
│   ├── imu_sensor.h/.cpp      # Includes mounting angle calibration
│   ├── gait_detection.h/.cpp
│   ├── stride_length.h/.cpp
│   ├── cadence.h/.cpp
│   ├── ble_comms.h/.cpp
│   ├── power_mgmt.h/.cpp
│   └── README.md
├── GaitTrackerX/              # iOS app (active Xcode project)
│   └── GaitTrackerX.xcodeproj
├── docs/
│   ├── breadboard_layout.md
│   └── datasheets/
├── test_sketches/             # Standalone hardware test sketches
├── RAD_Project_Briefing.md    # Full project context document
├── CHANGELOG.md
├── CLAUDE.md
└── README.md
```

---

## Authors

Hudson Howland and Brantley Field — PLTW Engineering Capstone, 2026
