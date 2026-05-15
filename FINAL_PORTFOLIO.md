# Final Portfolio — RAD: Running Analysis Device

**Team:** Hudson Howland and Brantley Field
**Class:** PLTW Engineering Capstone
**Date:** May 2026

---

## 1. Problem Statement

79% of recreational runners are injured each year, and 50-70% of those injuries are overuse injuries directly linked to poor running biomechanics. The primary correctable factor is cadence — the number of steps per minute. Research shows that a 5-10% increase in cadence significantly reduces knee and hip loading. Yet 60% of high school cross-country runners surveyed did not know their own cadence, and 75% expressed concern about past or future injury.

Professional gait analysis costs $350-500 per session and is not accessible to most runners. Existing wearable alternatives either cost $200 or more, use metrics that most runners do not understand, or are no longer available on the market. There is no affordable, accessible solution built specifically for high school athletes and recreational runners.

RAD — the Running Analysis Device — is our solution.

---

## 2. Project Proposal and Design Goals

RAD is a foot-mounted wearable that tracks running gait metrics in real time and sends data wirelessly to an iPhone via Bluetooth Low Energy. It is designed to cost under $60 total and be usable by any runner without any prior technical knowledge.

### Design Specifications

| Priority | Specification | Target |
|---|---|---|
| 1 | Total BOM cost | Under $60 |
| 2 | Cadence accuracy | Within 3 steps/min |
| 3 | Enclosure size | Max 50mm x 40mm x 20mm |
| 4 | Sampling rate | Minimum 100Hz |
| 5 | Battery life | Minimum 3 hours |
| 6 | Moisture resistance | IPX3 |

### Metrics to Track

- Cadence (steps per minute)
- Stride length (meters per step)
- Foot strike type (Heel / Midfoot / Forefoot)
- Distance (cumulative)
- Battery level

---

## 3. Hardware

### Bill of Materials

| Component | Part | Cost |
|---|---|---|
| Microcontroller | Arduino Nano 33 BLE Rev2 | ~$25 |
| IMU Sensor | MPU-6050 (GY-521) | ~$3 |
| Power Module | DFRobot MP2636 | ~$10 |
| Battery | 3.7V 700mAh LiPo | ~$8 |
| Enclosure | 3D printed PLA | ~$2 |
| **Total** | | **~$55** |

Design specification met: BOM is under $60.

### Wiring

```
MPU-6050 → Arduino Nano 33 BLE Rev2
  VCC → 3.3V
  GND → GND
  SCL → A5
  SDA → A4

MP2636 Power Module
  VOUT → Arduino VIN (5V regulated)
  GND → Arduino GND
  BAT+ → LiPo red wire
  BAT- → LiPo black wire
  Micro-USB port = charging input only
```

### Enclosure

3D printed in blue PLA. Dimensions: 50mm x 40mm x 20mm (meets design spec). Snap-fit two-part design for easy access to internals. Mounts to shoe laces via elastic strap.

---

## 4. Firmware

Written in C++ for Arduino Nano 33 BLE Rev2. Modular architecture across 6 files.

### How It Works

**Step 1 — Startup calibration:** The device samples the IMU for approximately 3 seconds on boot. First it removes gyroscope bias by averaging 100 samples at rest. Then it warms up the pitch filter and records the device's resting pitch angle from the shoe mounting position. This offset is stored and subtracted from all future pitch readings so classification thresholds work correctly regardless of how the device sits on the shoe.

**Step 2 — 100Hz sampling loop:** The main loop runs every 10ms. Each cycle reads the MPU-6050 accelerometer and gyroscope and updates the pitch angle estimate using a complementary filter (96% gyroscope, 4% accelerometer).

**Step 3 — Foot strike detection:** When Z-axis acceleration exceeds 1.5g and begins to decelerate, a foot strike is recorded. A 200ms debounce window prevents double-counting.

**Step 4 — Strike classification:** At the moment of impact, the corrected pitch angle determines strike type:
- Heel: below -15 degrees
- Midfoot: -15 to +5 degrees
- Forefoot: above +5 degrees

**Step 5 — Stride length:** The maximum swing angle during each stride is tracked. At each foot strike, stride length is calculated using the inverted pendulum model: `stride = 4 x legLength x sin(angle/2)`.

**Step 6 — Cadence:** A circular buffer stores the timestamps of the last 30 foot strikes. Cadence is calculated from the span of those timestamps. A minimum of 3 strikes is required before cadence is reported.

**Step 7 — BLE transmission:** After each foot strike, four BLE characteristics are updated: stride length (Float), cadence (UInt16), strike type (UInt8), and battery level (UInt8). The iPhone app receives these notifications in real time.

---

## 5. iOS App (GaitTracker)

Built in Swift/SwiftUI. Runs on iPhone via Bluetooth. Tested on physical hardware.

### Connection Screen
Scans for nearby Arduino devices. Animated pulsing rings provide visual feedback while scanning.

### Live Dashboard
Displays cadence, stride length, distance, duration, pace, and strike type in real time. The cadence card changes color based on performance: red (below 160 spm), orange (160-169), green (170-180 optimal), blue (above 180). Run start, pause, and stop controls.

### Run History
Shows all past runs as cards. Bar charts display cadence trend and distance for the last 7 runs. A donut chart shows overall strike type distribution across all saved runs. Charts appear automatically once 2 or more runs exist.

### Run Detail
Opens from any run card. Shows all metrics for that run. Includes a per-step strike distribution donut chart with step counts and percentages, and a cadence analysis bar that shows where the run falls on a 140-200 spm scale with the 170-180 optimal zone highlighted in green.

### Share Card
Generates a shareable PNG image for each run. Dark navy and purple gradient design. Shows distance, cadence, steps, duration, and strike type. Shared via the iOS system share sheet.

### Settings
Leg length slider from 0.6 to 1.1 meters (affects stride calculation accuracy). Imperial and metric unit toggle. Delete all history option.

---

## 6. Testing Results

### Field Test — Half-Mile Walk Test, May 1, 2026

| Metric | Recorded | Actual | Notes |
|---|---|---|---|
| Distance | 1.40 km | 0.84 km | 67% overestimate |
| Steps | 1,157 | — | Confirmed counting |
| Duration | 14:10 | — | Confirmed timing |
| Cadence | 74 spm | — | Expected for walking |
| Strike type | 100% Forefoot | Mixed | Mounting angle bias |

### Issues Found and Resolved

**Issue 1 — Forefoot classification bias**
The device was mounted at a forward angle on the shoe, adding a static pitch offset that pushed every detected pitch reading above the +5 degree forefoot threshold. Every step was classified as forefoot regardless of actual strike type.

Resolution: A mounting angle calibration routine was added to the firmware startup. The device now automatically measures its resting pitch angle when mounted on the shoe and subtracts that offset from all subsequent readings. This runs on every boot with no user input required.

**Issue 2 — Stride length overestimation**
The inverted pendulum model overestimated distance by approximately 67% during the walk test. The `STRIDE_CORRECTION_FACTOR` constant in the firmware is set to 1.0 and has not been tuned against real data.

Resolution: This requires a measured running test on a track of known distance. The correction factor should be adjusted until the device output matches the true distance. This is planned as the next field test.

### Design Specification Status

| Specification | Status |
|---|---|
| BOM under $60 | MET — approximately $55 |
| Enclosure max 50x40x20mm | MET |
| 100Hz sampling rate | MET |
| Cadence within 3 spm | Pending running field test |
| Battery minimum 3 hours | Pending test |
| IPX3 moisture resistance | Pending test |

---

## 7. Stakeholder Evaluation

Three external evaluators reviewed the prototype and provided structured feedback.

### Jackson — Peer / Cross-Country Runner

Validated the core concept, saying the device would help runners know when they are doing well or poorly, which would help change running form for the better. Primary concern was the physical enclosure — recommended adding padding and rounding the corners so it does not feel like a plastic box on the ankle. Willing to use and recommend the device once accuracy is demonstrated.

### Trey — Software Engineer

Called it an impressive first prototype and approved the data display approach of real-time metrics plus historical trend graphs. Raised questions about data privacy and storage. This was addressed: all data is stored locally on the user's iPhone using iOS storage with no cloud connection, no account required, and no external transmission of any kind. Said he would use the device if it proved reliable over extended use.

### Diana — Competitive Runner / Junior Olympic Athlete

Endorsed the concept strongly for high school runners who cannot access professional alternatives, noting the sub-$60 price point as a genuine competitive advantage. Recommended moving from ankle mounting to lace mounting, consistent with how professional pods like Stryd and Garmin Running Dynamics are worn. Asked for accuracy validation against a known device before full endorsement.

### Summary

All three stakeholders validated the core problem and confirmed the concept addresses it effectively. The recurring feedback themes were: improve the enclosure comfort, validate accuracy with a side-by-side comparison test, and confirm data stays private on the user's device.

---

## 8. Improvement Plans

### Based on Testing

The stride correction factor needs to be tuned against real running data on a track of known distance. The mounting angle calibration added during testing resolved the forefoot bias and should be extended to store the calibration value in device memory so the startup time is reduced.

### Based on External Evaluation

The enclosure should be redesigned with rounded edges, foam or silicone padding on contact surfaces, and a lower profile. The default mounting position should move to the lace top rather than the ankle based on evaluator feedback from the competitive runner. A short privacy statement should be added to the app Settings screen to address data security questions proactively.

### Based on Internal Evaluation

Field testing should have been scheduled immediately after the first successful BLE connection rather than at the end of the project. Hardware subsystems should be tested in isolation with a multimeter before being combined. The data model should be fully designed before any persistence code is written to avoid compatibility work mid-project.

### What to Do Differently

User interviews should happen before the enclosure is designed so feedback directly shapes hardware decisions. A ground truth test protocol should be defined before firmware is written. The BLE data format should be finalized first so firmware and app can be developed independently in parallel.

### Recommendations for a Similar Project

Test each hardware component in isolation before combining. Confirm IMU output in the serial monitor before touching BLE. Verify power module voltage with a multimeter before connecting anything. Build the iOS app against simulated data before hardware is ready. Decide on a mounting position at the start and do not change it. Schedule a field test date early and treat it as a hard deadline.

---

## 9. Competition Comparison

| Product | Price | Problem |
|---|---|---|
| RunScribe | $600 | Out of business |
| Stryd 5.0 | $200 | Uses power metric most runners do not understand |
| Lab gait analysis | $350-500/session | Not portable, not accessible |
| **RAD** | **~$55** | **Affordable, portable, accessible** |

---

## 10. Key Statistics

- 79% of recreational runners are injured annually (NIH)
- 50-70% of running injuries are overuse injuries from poor biomechanics
- 5-10% cadence increase significantly reduces knee and hip loading
- 170-180 spm is the widely accepted optimal cadence range
- $350-500 average cost for a single professional lab gait analysis session
- 60% of high school cross-country runners surveyed did not know their cadence
- 75% of those same runners expressed concern about past or future injury

---

## 11. Reflection

RAD began as a response to a real and well-documented problem: most runners get injured, most injuries are preventable, and the tools to prevent them are out of reach for high school athletes. The goal was to build something that actually works, costs less than a pair of running shoes, and fits in a pocket.

The hardware came together through iteration. The power module required troubleshooting a reversed JST connector polarity and understanding the onboard boost converter behavior. The firmware required careful ordering of operations — specifically that stride calculation must happen before the swing angle is reset, and that the peak detection logic depends on tracking acceleration across multiple samples. These were the kinds of bugs that only appear when the device is actually running on hardware.

The iOS app grew significantly beyond the original scope. What started as a basic dashboard became a full history system with charts, a per-run detail view with strike distribution graphs, a cadence analysis bar, and a shareable summary card. Each addition came from thinking about what a runner would actually want to see after a run.

The most important lesson from this project is that field testing should not be the last step. The walk test revealed two significant issues — the forefoot bias and the stride overestimate — that would not have been found at a desk. Both were fixable, but finding them earlier would have allowed more time to validate the fixes. Building a device is one thing; proving that it works is another, and that proof only comes from running in it.

---

*PLTW Engineering Capstone — Hudson Howland and Brantley Field — 2026*
