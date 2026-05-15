# Getting Started with Gait Tracker

Quick start guide to begin developing your running gait tracker device.

## What You Have Now

**Complete Project Structure**
- Arduino firmware skeleton (all 6 modules)
- iOS app structure and documentation
- Configuration files
- Complete implementation plan

## Next Steps: Phase 1 - Hardware Setup

### What You Need

**Hardware:**
- Arduino Nano 33 BLE Rev2
- MPU-6050 IMU module (GY-521 breakout)
- MP2636 Power Booster & Charger Module
- 3.7V 700mAh LiPo battery
- Breadboard
- Jumper wires
- Micro-USB cable (for programming)

**Software:**
- Arduino IDE (Download from arduino.cc)
- Serial monitor or terminal

### Step-by-Step Instructions

#### 1. Install Arduino IDE
```bash
# Download from: https://www.arduino.cc/en/software
# Install and launch Arduino IDE
```

#### 2. Install Required Libraries
In Arduino IDE:
1. Go to **Tools → Manage Libraries**
2. Search and install:
   - `ArduinoBLE` (by Arduino)
   - `Adafruit MPU6050` (by Adafruit)
   - `Adafruit Unified Sensor` (dependency)

#### 3. Configure Arduino IDE
1. Go to **Tools → Board → Arduino Mbed OS Nano Boards → Arduino Nano 33 BLE**
2. Select correct COM port: **Tools → Port**

#### 4. Assemble Breadboard
Connect components following this wiring:

```
MPU-6050          Arduino Nano 33 BLE Rev2
--------          -----------------------
VCC       →       3.3V
GND       →       GND
SCL       →       A5 (SCL pin)
SDA       →       A4 (SDA pin)

MP2636            Arduino Nano
------            ------------
5V OUT    →       VIN
GND       →       GND

LiPo Battery      MP2636
------------      ------
Red (+)   →       BAT+
Black (-) →       BAT-
```

**Important:** Use 3.3V for MPU-6050, NOT 5V!

#### 5. Test I2C Connection (CRITICAL)
Before proceeding, verify MPU-6050 is detected:

1. Open Arduino IDE
2. Go to **File → Examples → Wire → i2c_scanner**
3. Upload to Arduino Nano
4. Open **Tools → Serial Monitor** (set to 115200 baud)
5. You should see: `I2C device found at address 0x68`

If you don't see 0x68, check your wiring!

#### 6. Prepare Firmware for Upload
The firmware has placeholder code that needs libraries installed:

1. Open `gait_tracker/imu_sensor.cpp`
2. Uncomment the library includes at the top:
   ```cpp
   // TODO: Add MPU6050 library
   #include <Adafruit_MPU6050.h>
   #include <Adafruit_Sensor.h>
   ```

3. Uncomment the initialization code (search for "TODO: Replace")

4. Repeat for `gait_tracker/ble_comms.cpp`:
   ```cpp
   #include <ArduinoBLE.h>
   ```

#### 7. Upload Test Firmware
1. Open `gait_tracker/gait_tracker.ino` in Arduino IDE
2. Click **Verify** (checkmark icon) - should compile without errors
3. Click **Upload** (arrow icon)
4. Open **Serial Monitor** (magnifying glass icon)
5. Set baud rate to **115200**
6. You should see initialization messages

Expected output:
```
=== Gait Tracker Starting ===
Initializing IMU...
MPU6050 Found!
Calibrating IMU...
Calibration complete
Initializing BLE...
BLE service started. Device name: GaitTracker
...
```

#### 8. Verify BLE Advertising
On your iPhone:
1. Download "nRF Connect" app from App Store
2. Open app and tap "SCAN"
3. Look for device named "GaitTracker"
4. If you see it, BLE is working!

#### 9. Test Strike Detection
With device powered and serial monitor open:
1. Pick up the device
2. Tap it firmly on your desk
3. You should see in serial monitor:
   ```
   >>> Foot strike detected <<<
   Strike classified as: MIDFOOT (pitch: 2.3°)
   ```

If you see this, congratulations! Your hardware is working!

## Troubleshooting

### MPU-6050 Not Detected
- **Check wiring** - Especially SDA/SCL pins
- **Check voltage** - Must be 3.3V, not 5V
- **Try different I2C address** - Some modules use 0x69
  - Edit `config.h`: Change `MPU6050_ADDRESS` to `0x69`

### BLE Not Advertising
- **Verify board selection** - Must be "Arduino Nano 33 BLE"
- **Check library installation** - ArduinoBLE must be installed
- **Check serial output** - Look for error messages
- **Reboot device** - Disconnect and reconnect power

### No Serial Output
- **Check baud rate** - Must be 115200
- **Check COM port** - Correct port selected in Tools → Port
- **Try different USB cable** - Some cables are power-only

### Strike Detection Not Working
- **Tap harder** - Needs >2g acceleration
- **Check IMU orientation** - Z-axis should be vertical
- **Adjust threshold** - Edit `config.h`: `STRIKE_THRESHOLD`

## What's Next?

Once Phase 1 is complete:

### Phase 2: IMU Data Acquisition
- Implement sensor fusion algorithm
- Test orientation tracking
- Validate 100Hz sampling rate

### Phase 3: Gait Detection
- Tune strike detection threshold
- Test strike classification accuracy
- Validate cadence calculation

### Phase 4: BLE Communication
- Test data transmission to phone
- Verify characteristic updates
- Measure battery life

Then proceed through Phases 5-10 as outlined in [initial.md](initial.md).

## Getting Help

**Check these files:**
- [README.md](README.md) - Project overview
- [initial.md](initial.md) - Complete implementation plan
- [gait_tracker/README.md](gait_tracker/README.md) - Firmware details

**Common Issues:**
- Most problems are wiring-related - double-check connections
- I2C scanner is your best debugging tool
- Serial monitor shows detailed debug output

## Quick Reference

**Arduino Commands:**
- Compile: Ctrl+R (Cmd+R on Mac)
- Upload: Ctrl+U (Cmd+U on Mac)
- Serial Monitor: Ctrl+Shift+M (Cmd+Shift+M on Mac)

**Important Pins:**
- SDA: A4
- SCL: A5
- MPU-6050 Power: 3.3V (NOT 5V!)

**Key Constants** (in config.h):
- `STRIKE_THRESHOLD` - Adjust for sensitivity
- `IMU_READ_INTERVAL` - 10ms = 100Hz
- `DEBUG_MODE` - Set to `true` for verbose output

Good luck building your gait tracker!
