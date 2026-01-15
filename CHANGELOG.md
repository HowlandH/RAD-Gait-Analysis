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
