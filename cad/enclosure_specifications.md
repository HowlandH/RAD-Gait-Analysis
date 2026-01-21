# Gait Tracker Enclosure - Inventor CAD Specifications

Complete dimensional specifications for building the enclosure in Autodesk Inventor.

## Component Dimensions (All measurements in mm)

### Arduino Nano 33 BLE Rev2
- **Length:** 45.0 mm
- **Width:** 18.0 mm
- **Height:** 5.0 mm (PCB + components)
- **Mounting holes:** 2.0 mm diameter, located 2.0 mm from each corner
- **Micro-USB connector:**
  - Width: 8.0 mm
  - Height: 3.0 mm
  - Protrusion from board edge: 6.0 mm
  - Located: Centered on short edge

### MPU-6050 (GY-521 Breakout)
- **Length:** 21.0 mm
- **Width:** 16.0 mm
- **Height:** 3.0 mm (PCB + sensor)
- **Mounting holes:** 2.0 mm diameter, located at corners

### MP2636 Power Module (DFRobot DFR0446)
- **Length:** 28.0 mm
- **Width:** 18.0 mm
- **Height:** 4.0 mm
- **Micro-USB connector (charging input):**
  - Width: 8.0 mm
  - Height: 3.0 mm
  - Located: Side edge, centered
- **USB-A connector (5V output):**
  - Width: 14.0 mm
  - Height: 7.0 mm
  - Located: Same side as Micro-USB, opposite end

### 3.7V 700mAh LiPo Battery
- **Length:** 50.0 mm
- **Width:** 34.0 mm
- **Height:** 6.0 mm

## Enclosure Design Parameters

### General Settings
- **Wall thickness:** 2.0 mm
- **Clearance around components:** 1.0 mm
- **Corner radius:** 3.0 mm (external), 2.0 mm (internal)
- **Mounting post diameter:** 3.0 mm
- **Screw hole diameter:** 2.0 mm (for M2 screws)
- **Lid lip depth:** 1.5 mm

### Calculated Overall Dimensions
- **Internal cavity:**
  - Length: 52.0 mm (battery length + 2mm clearance)
  - Width: 58.0 mm (18 + 16 + 18 + 6mm clearance)
  - Height: 8.0 mm (max component height + 2mm clearance)

- **External dimensions:**
  - Length: 56.0 mm
  - Width: 62.0 mm
  - Height (bottom): 10.0 mm
  - Height (lid): 2.0 mm

## Inventor Modeling Instructions

### Part 1: Enclosure Bottom

#### Step 1: Create Base Sketch (XY Plane)
1. Create new part file
2. Start sketch on XY plane
3. Draw rectangle: 56.0 mm × 62.0 mm, centered on origin
4. Fillet all corners with 3.0 mm radius
5. Finish sketch

#### Step 2: Extrude Base
1. Extrude sketch: 10.0 mm (upward, positive Z)
2. Result: Solid box with rounded corners

#### Step 3: Create Internal Cavity
1. Start sketch on top face
2. Offset internal edge by 2.0 mm (inward)
3. Fillet internal corners with 2.0 mm radius
4. Finish sketch
5. Extrude cut: 8.0 mm depth (downward into solid)
6. Result: Hollow box with 2.0 mm walls and 2.0 mm floor

#### Step 4: Micro-USB Access Port (Arduino)
1. Start sketch on front face (short edge)
2. Draw rectangle:
   - Width: 8.0 mm
   - Height: 3.0 mm
   - Position:
     - Centered horizontally
     - 3.0 mm from top edge
     - 3.0 mm from internal floor (5.0 mm from bottom)
3. Extrude cut: Through wall (2.0 mm depth)

#### Step 5: Micro-USB Access Port (MP2636)
1. Start sketch on side face (long edge)
2. Draw rectangle:
   - Width: 8.0 mm
   - Height: 3.0 mm
   - Position: Calculate based on MP2636 placement (see component layout below)
3. Extrude cut: Through wall

#### Step 6: USB-A Access Port (MP2636)
1. Start sketch on same side face
2. Draw rectangle:
   - Width: 14.0 mm
   - Height: 7.0 mm
   - Position: Below Micro-USB port
3. Extrude cut: Through wall

#### Step 7: Mounting Posts
Create cylindrical posts for each component mounting hole:

**Post specifications:**
- Diameter: 3.0 mm
- Height: 7.0 mm (from floor to component level)
- Screw hole: 2.0 mm diameter, through center

**Arduino posts (4 positions):**
- Origin reference: Front-left corner of internal cavity
- Post 1: X=4.0, Y=4.0
- Post 2: X=47.0, Y=4.0
- Post 3: X=4.0, Y=18.0
- Post 4: X=47.0, Y=18.0

**MPU-6050 posts (2 positions):**
- Origin reference: Same
- Post 1: X=4.0, Y=24.0
- Post 2: X=23.0, Y=38.0

**MP2636 posts (2 positions):**
- Origin reference: Same
- Post 1: X=4.0, Y=44.0
- Post 2: X=30.0, Y=60.0

#### Step 8: Lid Retention Lip
1. Start sketch on top edge of cavity
2. Create rectangle offset 1.5 mm inward from cavity edge
3. Extrude upward: 2.0 mm
4. Shell feature: 2.0 mm wall thickness (hollow out the lip)

#### Step 9: Corner Screw Bosses (for lid attachment)
Create 4 cylindrical bosses:
- Position: 4.0 mm from each external corner
- Diameter: 4.0 mm
- Height: Full height (10.0 mm from floor)
- Countersunk hole:
  - 2.0 mm diameter through
  - 4.0 mm diameter × 1.0 mm deep countersink at bottom

### Part 2: Enclosure Lid

#### Step 1: Create Base Sketch
1. Create new part file
2. Start sketch on XY plane
3. Draw rectangle: 56.0 mm × 62.0 mm, centered on origin
4. Fillet all corners with 3.0 mm radius
5. Finish sketch

#### Step 2: Extrude Lid
1. Extrude sketch: 2.0 mm upward
2. Result: Flat lid with rounded corners

#### Step 3: Corner Screw Holes
Create 4 screw holes:
- Position: 4.0 mm from each corner (match bottom screw bosses)
- Diameter: 2.2 mm (clearance for M2 screw)
- Depth: Through all (2.0 mm)

#### Step 4: Ventilation Slots
Create 5 rectangular slots for ventilation:
- Dimensions: 2.0 mm wide × 20.0 mm long
- Spacing: 7.0 mm center-to-center
- Position: Centered on lid
- Depth: Through all

### Component Layout (Internal Cavity Reference)

All positions measured from front-left corner (0,0) of internal cavity floor:

#### Arduino Nano 33 BLE Rev2
- Position: X=2.0, Y=2.0
- Orientation: USB connector facing front edge
- Elevation: 7.0 mm above floor (on mounting posts)

#### MPU-6050
- Position: X=2.0, Y=22.0
- Orientation: Sensor facing up
- Elevation: 7.0 mm above floor

#### MP2636 Power Module
- Position: X=2.0, Y=42.0
- Orientation: USB connectors facing side edge
- Elevation: 7.0 mm above floor

#### LiPo Battery
- Position: X=30.0, Y=14.0
- Orientation: Flat, wires toward components
- Elevation: 2.0 mm above floor (rests on floor with clearance)

## Assembly Hardware

### Required Screws
- **Component mounting:** 8× M2 × 10mm screws (for mounting posts)
- **Lid attachment:** 4× M2 × 8mm screws (for corner bosses)

### Assembly Sequence
1. Install Arduino Nano on mounting posts (4 screws)
2. Install MPU-6050 on mounting posts (2 screws)
3. Install MP2636 on mounting posts (2 screws)
4. Place battery in cavity
5. Route wires as needed
6. Attach lid (4 screws)

## Material Recommendations

### 3D Printing
- **Material:** PLA or PETG
- **Layer height:** 0.2 mm
- **Wall thickness:** 3 perimeters minimum
- **Infill:** 20%
- **Supports:** None required (design is support-free)

### CNC Machining
- **Material:** ABS plastic or aluminum
- **Tolerances:** ±0.1 mm

## Design Notes

1. **USB Access:** All USB ports are accessible from the exterior for charging and programming
2. **Ventilation:** Lid slots allow heat dissipation from Arduino and power module
3. **Wire Routing:** Space between battery and components allows for wire routing
4. **Mounting:** All components are elevated 7mm above floor to allow wire routing underneath
5. **Serviceability:** Lid is easily removable for repairs and modifications

## Optional Enhancements

### Belt Clip
Add to back face:
- Position: Centered on long edge
- Style: Integrated clip or mounting holes for commercial clip
- Dimensions: 25mm wide × 10mm tall

### Status LED Window
Add to lid:
- Position: Above Arduino location
- Dimensions: 3mm diameter clear window
- Purpose: View Arduino onboard LED

### Strap Attachment Points
Add to each end:
- Position: Centered on short edges
- Style: 10mm diameter holes or loops
- Purpose: Attach elastic strap for mounting to leg

## Drawing Views for Inventor

### Recommended Views for Documentation
1. **Isometric view** - Overall assembly
2. **Top view** - Component layout
3. **Front section view (A-A)** - Show internal cavity and mounting posts
4. **Side section view (B-B)** - Show USB access ports
5. **Exploded view** - Assembly sequence

## File Organization

Suggested file naming:
- `gait_tracker_bottom.ipt` - Enclosure bottom
- `gait_tracker_lid.ipt` - Enclosure lid
- `gait_tracker_assembly.iam` - Assembly file
- `gait_tracker_drawing.idw` - Engineering drawing

---

**Created:** 2026-01-21
**Project:** RAD Gait Analysis Tracker
**Revision:** 1.0
