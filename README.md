# Running Gait Tracker

An affordable (<$60) foot-mounted device that tracks running gait metrics in real-time and transmits data via Bluetooth Low Energy to an iOS companion app.

## Project Overview

**Target Users:** High school cross-country runners and recreational athletes

**Metrics Tracked:**
- **Cadence** - Steps per minute (±3 step accuracy)
- **Stride Length** - Distance per step
- **Foot Strike Pattern** - Heel/Midfoot/Forefoot classification

**Design Goals:**
- Total BOM < $60
- Enclosure ≤ 50mm × 40mm × 20mm
- Battery life ≥ 3 hours
- 100 Hz sampling rate
- Temperature range: 35-100°F
- IPX3 moisture resistance

## System Components

### Hardware
- **Arduino Nano 33 BLE Rev2** - Main microcontroller with built-in BLE
- **MPU-6050** - 6-axis IMU (accelerometer + gyroscope)
- **MP2636 Power Module** - Battery management and charging
- **3.7V 700mAh LiPo Battery** - Power source
- **3D Printed Enclosure** - PLA with rubber dampening

### Firmware (Arduino C++)
Modular architecture with 6 core components:
- IMU Data Acquisition
- Gait Detection
- Stride Length Estimation
- Cadence Calculation
- BLE Communication
- Power Management

### iOS App (Swift/SwiftUI)
- Real-time metrics dashboard
- Run history and statistics
- BLE connection management
- Data export (CSV/GPX)

## Repository Structure

```
├── gait_tracker/          # Arduino firmware
│   ├── gait_tracker.ino   # Main sketch
│   ├── config.h           # Configuration constants
│   ├── imu_sensor.*       # IMU interface
│   ├── gait_detection.*   # Strike detection & classification
│   ├── stride_length.*    # Stride estimation
│   ├── cadence.*          # Cadence calculation
│   ├── ble_comms.*        # BLE service
│   ├── power_mgmt.*       # Power management
│   └── README.md
│
├── GaitTracker/           # iOS app (to be created)
│   ├── Views/
│   ├── Models/
│   ├── Managers/
│   └── Resources/
│
├── enclosure/             # 3D CAD files (to be created)
│   ├── GaitTracker_Enclosure.ipt
│   ├── case_top.stl
│   └── case_bottom.stl
│
├── docs/                  # Documentation
├── tests/                 # Test data and scripts
├── initial.md             # Complete implementation plan
├── CLAUDE.md              # AI assistant guidance
└── README.md              # This file
```

## Quick Start

### Arduino Firmware Setup
1. Install Arduino IDE
2. Install required libraries: ArduinoBLE, Adafruit MPU6050
3. Open `gait_tracker/gait_tracker.ino`
4. Select board: Arduino Nano 33 BLE
5. Upload to board

See [gait_tracker/README.md](gait_tracker/README.md) for detailed instructions.

### iOS App Setup
Coming in Phase 5

## Development Phases

Current phase: **PHASE 1 - Hardware Setup & Verification**

1. ✅ **Project Setup** - Create directory structure and initial files
2. ⏳ **Hardware Setup** - Assemble breadboard and test components
3. ⏳ **IMU Data Acquisition** - Build sensor reading pipeline
4. ⏳ **Gait Detection** - Implement strike detection algorithms
5. ⏳ **BLE Communication** - Set up Bluetooth data transmission
6. ⏳ **iOS App** - Create app with real-time dashboard
7. ⏳ **Enclosure Design** - Design and print protective case
8. ⏳ **System Integration** - Assemble complete device
9. ⏳ **Field Testing** - Validate accuracy on treadmill and track
10. ⏳ **Algorithm Tuning** - Refine based on field data
11. ⏳ **Documentation** - Create user manual and technical docs

See [initial.md](initial.md) for complete implementation plan.

## Bill of Materials

| Component | Quantity | Est. Cost |
|-----------|----------|-----------|
| Arduino Nano 33 BLE Rev2 | 1 | $27.00 |
| MPU-6050 IMU | 1 | $5.00 |
| MP2636 Power Module | 1 | $8.00 |
| 3.7V 700mAh LiPo Battery | 1 | $8.00 |
| PLA Filament (~20g) | 1 | $0.40 |
| Rubber dampening | 1 | $2.00 |
| Elastic straps | 2 | $3.00 |
| USB-C Cable | 1 | $3.00 |
| Breadboard + Wires | 1 | $5.00 |

**Total:** ~$56.40 ✓ (Meets <$60 requirement)

## Key Algorithms

### Strike Classification
Uses pitch angle at moment of impact:
- **Heel strike:** Pitch < -15° (foot tilted back)
- **Midfoot strike:** Pitch -15° to +5° (foot flat)
- **Forefoot strike:** Pitch > +5° (foot tilted forward)

### Stride Length Estimation
Inverted pendulum model:
```
stride_length = 4 × leg_height × sin(swing_angle / 2)
```

### Cadence Calculation
Circular buffer tracking last 30 foot strikes:
```
cadence = (strike_count - 1) / time_span × 60
```

## Testing

### Desktop Testing
- I2C scanner for MPU-6050 detection
- Serial monitor at 115200 baud
- Tap device at known cadence with metronome
- nRF Connect app for BLE verification

### Field Testing
- Treadmill: Compare to display metrics
- Track: Validate over 400m × 4 laps
- Video: Slow-motion strike validation
- Battery: Full charge to depletion test

## Success Criteria

- ✓ Cadence accuracy: ±3 steps/min
- ✓ Stride length accuracy: ±5%
- ✓ Strike classification: >80% agreement
- ✓ Battery life: ≥3 hours
- ✓ BLE connection: Stable for entire run

## Documentation

- [initial.md](initial.md) - Complete 10-phase implementation plan
- [CLAUDE.md](CLAUDE.md) - AI assistant guidance
- [gait_tracker/README.md](gait_tracker/README.md) - Firmware documentation

## License

This project is for educational purposes.

## Authors

Hudson Howland
Brantley Field