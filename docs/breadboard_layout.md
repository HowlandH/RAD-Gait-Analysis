# Breadboard Layout Guide

Complete wiring diagram and assembly instructions for the Gait Tracker breadboard prototype.

## Components Required

| Component | Quantity | Notes |
|-----------|----------|-------|
| Arduino Nano 33 BLE Rev2 | 1 | Main microcontroller |
| MPU-6050 (GY-521 breakout) | 1 | 6-axis IMU sensor |
| MP2636 Power Module | 1 | Battery charger & booster |
| 3.7V 700mAh LiPo Battery | 1 | Power source |
| Full-size breadboard | 1 | 830 tie points recommended |
| Male-to-male jumper wires | ~10 | Various colors recommended |
| Micro-USB cable | 1 | For programming Arduino |

## Visual Layout

```
                    BREADBOARD TOP VIEW
    ============================================================

    (+) Red Power Rail    ─────────────────────────────────── (+)
    (-) Blue Ground Rail  ─────────────────────────────────── (-)

    ============================================================

         MPU-6050 (GY-521)              Arduino Nano 33 BLE Rev2
         ┌──────────┐                   ┌────────────────────┐
         │          │                   │                    │
         │   VCC ●──┼───RED─────────────┼──● 3.3V           │
         │   GND ●──┼───BLACK───────────┼──● GND            │
         │   SCL ●──┼───YELLOW──────────┼──● A5 (SCL)       │
         │   SDA ●──┼───GREEN───────────┼──● A4 (SDA)       │
         │   XDA ●  │                   │                    │
         │   XCL ●  │                   │  ● VIN ────────────┼──ORANGE──┐
         │   AD0 ●  │                   │  ● GND ────────────┼──BROWN───┼──┐
         │   INT ●  │                   │                    │          │  │
         └──────────┘                   └────────────────────┘          │  │
                                                                         │  │
                                        MP2636 Power Module              │  │
                                        ┌──────────────┐                │  │
                                        │ Micro-USB IN │ (for charging) │  │
                                        │  USB-A OUT   │ (5V output)    │  │
                                        │  VOUT   ●────┼────────────────┘  │
                                        │  GND    ●────┼───────────────────┘
                                        │              │
                                        │  BAT+   ●────┼───RED──┐
                                        │  BAT-   ●────┼───BLACK┤
                                        └──────────────┘        │
                                                                │
                                        3.7V LiPo Battery       │
                                        ┌──────────────┐        │
                                        │   700mAh     │        │
                                        │  +  ●────────┼────────┘
                                        │  -  ●────────┼────────┐
                                        └──────────────┘        │
                                                                │
                                    (connects to BAT- above) ───┘
```

## Step-by-Step Assembly

### Step 1: Position Components on Breadboard

**Layout from left to right:**

1. **MPU-6050** - Place in leftmost section (rows 1-8)
2. **Arduino Nano 33 BLE Rev2** - Center section (rows 1-30, straddling center gap)
3. **MP2636 Power Module** - Right section (rows 1-10)
4. **LiPo Battery** - Off-board, connected via wires

**Tip:** Leave space between components for wiring and future debugging.

### Step 2: MPU-6050 to Arduino Connections

#### Connection 1: Power (VCC)
- **From:** MPU-6050 `VCC` pin
- **To:** Arduino Nano `3.3V` pin
- **Wire Color:** RED (recommended)
- **CRITICAL:** Use 3.3V, NOT 5V! The MPU-6050 is not 5V tolerant!

#### Connection 2: Ground (GND)
- **From:** MPU-6050 `GND` pin
- **To:** Arduino Nano `GND` pin
- **Wire Color:** BLACK (recommended)

#### Connection 3: I2C Clock (SCL)
- **From:** MPU-6050 `SCL` pin
- **To:** Arduino Nano `A5` pin (hardware I2C clock)
- **Wire Color:** YELLOW (recommended)

#### Connection 4: I2C Data (SDA)
- **From:** MPU-6050 `SDA` pin
- **To:** Arduino Nano `A4` pin (hardware I2C data)
- **Wire Color:** GREEN (recommended)

**Leave unconnected:**
- `XDA` - Auxiliary data (not used)
- `XCL` - Auxiliary clock (not used)
- `AD0` - I2C address select (leave floating for 0x68)
- `INT` - Interrupt pin (not used in Phase 1, may use later for motion wake)

### Step 3: MP2636 to Arduino Connections

#### Connection 5: 5V Power Output
- **From:** MP2636 `VOUT` pin
- **To:** Arduino Nano `VIN` pin
- **Wire Color:** ORANGE (recommended)
- **Note:** This powers the Arduino from the battery

#### Connection 6: Ground
- **From:** MP2636 `GND` pin
- **To:** Arduino Nano `GND` pin (same ground as MPU-6050)
- **Wire Color:** BROWN (recommended)

### Step 4: Battery to MP2636 Connections

#### Connection 7: Battery Positive
- **From:** LiPo Battery RED wire (+)
- **To:** MP2636 `BAT+` pin
- **IMPORTANT:** Double-check polarity! Reversed polarity can damage battery or module!

#### Connection 8: Battery Negative
- **From:** LiPo Battery BLACK wire (-)
- **To:** MP2636 `BAT-` pin

### Step 5: USB Connection for Charging

- **Plug Micro-USB cable into MP2636 module** (not the Arduino)
- **Connect to USB power adapter or computer** to charge battery
- **Note:** The USB-A port is a 5V OUTPUT (alternative to VOUT pin), not for charging
- **LED indicator on MP2636** will show charging status:
  - Red = Charging
  - Green = Fully charged

## Wiring Summary Table

| Connection | From | To | Wire Color | Notes |
|------------|------|-----|------------|-------|
| 1 | MPU-6050 VCC | Arduino 3.3V | RED | Must be 3.3V! |
| 2 | MPU-6050 GND | Arduino GND | BLACK | Common ground |
| 3 | MPU-6050 SCL | Arduino A5 | YELLOW | I2C clock |
| 4 | MPU-6050 SDA | Arduino A4 | GREEN | I2C data |
| 5 | MP2636 VOUT | Arduino VIN | ORANGE | Powers Arduino |
| 6 | MP2636 GND | Arduino GND | BROWN | Common ground |
| 7 | LiPo + (red) | MP2636 BAT+ | RED | Check polarity! |
| 8 | LiPo - (black) | MP2636 BAT- | BLACK | Check polarity! |

## Power Flow Diagram

```
┌─────────────┐
│  LiPo 3.7V  │
│   700mAh    │
└──────┬──────┘
       │
       ▼
┌─────────────┐       USB-C (charging)
│   MP2636    │◄──────────────────
│  Booster +  │
│   Charger   │
└──────┬──────┘
       │ 5V regulated
       ▼
┌─────────────┐
│  Arduino    │
│  Nano 33    │ 3.3V out
│  BLE Rev2   ├──────┐
└─────────────┘      │
                     ▼
              ┌─────────────┐
              │  MPU-6050   │
              │   IMU       │
              └─────────────┘
```

## Important Safety Notes

### CRITICAL WARNINGS

1. **MPU-6050 VOLTAGE:**
   - MUST use 3.3V, NOT 5V
   - The MPU-6050 is not 5V tolerant
   - Using 5V will permanently damage the sensor

2. **BATTERY POLARITY:**
   - Always double-check red (+) and black (-) connections
   - Reversed polarity can cause fire or explosion
   - If unsure, use a multimeter to verify

3. **BATTERY HANDLING:**
   - Never short-circuit the battery
   - Never puncture or damage the battery
   - Keep away from metal objects
   - Store in fireproof container when not in use

4. **CHARGING:**
   - Only charge with MP2636 module or proper LiPo charger
   - Never leave charging unattended
   - Charge in fireproof area
   - Disconnect if battery gets hot

## Testing Checklist

After assembly, verify each step:

###Visual Inspection
- [ ] All wires seated firmly in breadboard holes
- [ ] No loose connections
- [ ] MPU-6050 connected to 3.3V (not 5V)
- [ ] Battery polarity correct (red to BAT+, black to BAT-)
- [ ] No wires crossed or touching

###Power-On Test (without USB programming cable)
- [ ] Connect battery to MP2636
- [ ] Arduino power LED should light up
- [ ] MPU-6050 power LED should light up (if equipped)
- [ ] No smoke, burning smell, or excessive heat

###I2C Communication Test
- [ ] Connect Arduino to computer via Micro-USB
- [ ] Upload I2C scanner sketch
- [ ] Open Serial Monitor (115200 baud)
- [ ] Verify MPU-6050 detected at address 0x68

Expected I2C scanner output:
```
I2C Scanner
Scanning...
I2C device found at address 0x68  !
done
```

###IMU Data Test
- [ ] Upload basic MPU-6050 test sketch
- [ ] Verify accelerometer readings (~1g on Z-axis when flat)
- [ ] Move device and observe values change
- [ ] Gyroscope should read near 0 when stationary

## Troubleshooting

### MPU-6050 Not Detected (no device at 0x68)

**Check:**
1. VCC connected to 3.3V (not 5V)?
2. GND connected properly?
3. SDA connected to A4?
4. SCL connected to A5?
5. All wires firmly inserted?

**Try:**
- Re-seat all MPU-6050 connections
- Swap jumper wires (could be faulty wire)
- Try address 0x69 (some modules have AD0 pulled high)

### Arduino Not Powering On

**Check:**
1. Battery charged? (use multimeter: should read ~3.7-4.2V)
2. MP2636 VOUT connected to Arduino VIN?
3. Common ground between MP2636 and Arduino?
4. Battery polarity correct?

**Try:**
- Charge battery via Micro-USB on MP2636
- Test with Arduino connected to computer USB (bypasses battery)
- Use multimeter to verify 5V on MP2636 VOUT or USB-A output

### Accelerometer Readings Wrong

**Expected when flat on table:**
- X-axis: ~0 g
- Y-axis: ~0 g
- Z-axis: ~1 g (9.8 m/s² or ~1g)

**If readings are off:**
- MPU-6050 may need calibration
- Check if sensor is flat and stable
- Verify 3.3V power supply is stable

## Next Steps After Successful Assembly

Once breadboard is working:

1. **Upload gait_tracker firmware** ([Getting Started Guide](../GETTING_STARTED.md))
2. **Test BLE advertising** (nRF Connect app)
3. **Simulate foot strikes** (tap device on desk)
4. **Proceed to Phase 2** (IMU data acquisition)

## Photos Reference (to be added)

Take photos of your breadboard from multiple angles for reference:
- [ ] Top view showing all components
- [ ] Close-up of MPU-6050 connections
- [ ] Close-up of power connections
- [ ] Label photo with wire colors

## Advanced: Optional Connections for Future Phases

### Battery Voltage Monitoring (Phase 4)
Add voltage divider to measure battery level:

```
Battery + ────┬────── MP2636 BAT+
              │
           10kΩ resistor
              │
              ├────────── Arduino A0 (analog input)
              │
           10kΩ resistor
              │
Battery - ────┴────── MP2636 BAT-
```

### MPU-6050 Interrupt (Phase 7)
For motion detection wake-up:

```
MPU-6050 INT ─────── Arduino D2 (interrupt pin)
```

These are not needed for Phase 1 testing.

---

**Assembly time:** ~15-20 minutes
**Difficulty:** Beginner-friendly (no soldering required)
**Cost:** ~$56 (see Bill of Materials in main README)
