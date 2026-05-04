# RAD Project Briefing — Running Analysis Device

## What It Is
A foot-mounted wearable that tracks running gait metrics in real time and sends data wirelessly to an iPhone app via Bluetooth Low Energy (BLE). Built for recreational runners and high school athletes who cannot afford professional lab gait analysis ($350-500/session). Total device cost is under $60.

## Team
- Hudson Howland and Brantley Field
- PLTW Engineering Capstone

---

## Hardware Components
| Component | Part | Cost |
|---|---|---|
| Microcontroller | Arduino Nano 33 BLE Rev2 | ~$25 |
| IMU Sensor | MPU-6050 (GY-521) | ~$3 |
| Power Module | DFRobot MP2636 | ~$10 |
| Battery | 3.7V 700mAh LiPo | ~$8 |
| Enclosure | 3D printed PLA | ~$2 |
| **Total BOM** | | **~$55** |

Enclosure dimensions: 50mm x 40mm x 20mm. Mounts to shoe laces via elastic strap. Snap-fit two-part design for easy access to internals.

---

## What It Measures
1. **Cadence** — steps per minute (optimal: 170-180 spm)
2. **Stride length** — meters per step using inverted pendulum model
3. **Foot strike type** — Heel / Midfoot / Forefoot classified by pitch angle at moment of impact
4. **Distance** — cumulative, calculated from stride length
5. **Battery level** — percentage remaining

---

## How It Works (Firmware)
- Samples IMU at 100Hz
- Detects foot strikes via Z-axis acceleration peak detection with 200ms debounce to prevent false positives
- Classifies strike type by pitch angle at impact: Heel = below -15 degrees, Forefoot = above +5 degrees, Midfoot = between
- Calculates stride length using inverted pendulum model: stride = 4 x legLength x sin(angle/2)
- Cadence calculated from circular buffer of recent strike timestamps
- Transmits 4 BLE characteristics to iPhone:
  - Stride length (Float, 4 bytes)
  - Cadence (UInt16, 2 bytes)
  - Strike type (UInt8: 0=Heel, 1=Midfoot, 2=Forefoot)
  - Battery level (UInt8, percentage)

---

## iOS App (GaitTracker)
Built in Swift/SwiftUI. Runs on iPhone via Bluetooth. Features:

**Connection Screen**
- Scans for and connects to the Arduino device
- Animated pulsing Bluetooth rings while scanning

**Live Dashboard**
- Cadence hero card — color changes by performance (red = low, orange = approaching, green = optimal, blue = high)
- Stride length, distance, duration, pace, strike type displayed live
- Start / Pause / Stop run controls

**History Screen**
- Run history cards showing all past runs
- Bar charts: cadence trend and distance per run (last 7 runs)
- Donut chart: strike type distribution across all runs
- Charts appear automatically when 2 or more runs exist

**Run Detail Screen**
- Opens when you tap any run card
- Shows all metrics for that specific run
- Per-step strike distribution donut chart with counts and percentages
- Cadence analysis bar showing where the run lands on the 140-200 spm scale with the 170-180 optimal zone highlighted
- Performance assessment message

**Share Card**
- Generates a shareable PNG image for each run
- Dark navy/purple gradient design
- Shows distance, cadence, steps, duration, strike type

**Settings**
- Leg length slider (affects stride calculation accuracy)
- Imperial/metric toggle
- Delete all history

---

## Design Specifications
| Priority | Specification | Status |
|---|---|---|
| 1 (Cost) | BOM under $60 | MET |
| 2 (Functionality) | Cadence within 3 spm accuracy | Pending field test |
| 3 (Size) | Enclosure max 50x40x20mm | MET |
| 4 (Data Rate) | Minimum 100Hz sampling | MET |
| 5 (Battery) | Minimum 3 hours continuous | Pending test |
| 6 (Durability) | IPX3 moisture resistance | Pending test |

---

## Current Status
- **Firmware:** Fully working. BLE transmitting all 4 characteristics confirmed.
- **iOS App:** Built and running on physical iPhone. All features working.
- **Enclosure:** 3D printed in blue PLA. Snap-fit design complete.
- **Field Testing:** NOT yet completed. No real cadence accuracy numbers yet.
- **Pending:** Battery life test, waterproofing test, cadence accuracy vs metronome

---

## Competition
| Product | Price | Problem |
|---|---|---|
| RunScribe | $600 | Out of business |
| Stryd 5.0 | $200 | Uses "power" metric most runners don't understand |
| Lab gait analysis | $350-500/session | Not portable, not accessible |
| **RAD** | **<$60** | **Our solution** |

---

## Key Statistics
- **79%** of recreational runners get injured annually (NIH)
- **50-70%** of running injuries are overuse injuries from poor biomechanics
- **20-40x** increased injury risk when jumping mileage without fixing form
- **170-180 spm** is the widely accepted optimal cadence range
- **5-10%** cadence increase significantly reduces knee and hip loading (Journal of Orthopaedic & Sports Physical Therapy)
- **$350-500** average cost for a single professional lab gait analysis session
- **60%** of high school cross-country runners surveyed didn't know their cadence
- **75%** of those same runners expressed concern about past or future injury

---

## What the Existing Slides Are Missing
- Screenshots of the working iOS app (dashboard, history charts, run detail, share card)
- Photos of the final assembled device on a shoe
- Actual field test data (cadence accuracy numbers, battery life)
- A clear before/after story showing how RAD fixes the problem
- A compelling cost comparison visual ($350 lab vs $60 RAD)
- Demo or video of the device working in real time

---

## Suggested Slide Structure (16 slides)
1. Title — "RAD: The Running Analysis Device"
2. The Problem — 79% stat as hero number
3. Why Runners Get Hurt — cadence / overstriding / no feedback
4. Current Solutions All Fail — competition comparison
5. Our Solution — one sentence + device photo
6. Who It's For — stakeholders
7. Key Statistics — large visual callouts
8. How It Works — system diagram (sensor → BLE → iPhone)
9. The Hardware — component photo + BOM table
10. The App — screenshots of dashboard and history
11. Design Specifications — table
12. Prototype Evolution — first (red box) to final (blue box)
13. Testing Plan — checklist
14. Safety — electrical / physical / software
15. Future Improvements — top 6 items, 3 categories
16. References
