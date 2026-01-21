/*
 * Gait Tracker Enclosure
 *
 * Enclosure for:
 * - Arduino Nano 33 BLE Rev2
 * - MPU-6050 (GY-521 breakout)
 * - MP2636 Power Module (DFRobot DFR0446)
 * - 3.7V 700mAh LiPo Battery
 *
 * To generate STL:
 * 1. Install OpenSCAD (openscad.org)
 * 2. Open this file
 * 3. Press F6 to render
 * 4. File -> Export -> Export as STL
 */

// ============================================================================
// COMPONENT DIMENSIONS (mm)
// ============================================================================

// Arduino Nano 33 BLE Rev2
arduino_length = 45;
arduino_width = 18;
arduino_height = 5;  // PCB thickness + components
arduino_usb_height = 3;
arduino_usb_width = 8;
arduino_usb_depth = 6;

// MPU-6050 GY-521 Breakout
mpu_length = 21;
mpu_width = 16;
mpu_height = 3;

// MP2636 Power Module (DFRobot DFR0446)
mp2636_length = 28;
mp2636_width = 18;
mp2636_height = 4;
mp2636_usb_micro_width = 8;
mp2636_usb_micro_height = 3;
mp2636_usb_a_width = 14;
mp2636_usb_a_height = 7;

// LiPo Battery 700mAh (typical dimensions)
battery_length = 50;
battery_width = 34;
battery_height = 6;

// Enclosure parameters
wall_thickness = 2;
clearance = 1;  // Space around components
mounting_post_diameter = 3;
screw_hole_diameter = 2;
lid_lip = 1.5;

// ============================================================================
// CALCULATED DIMENSIONS
// ============================================================================

internal_length = battery_length + clearance * 2;
internal_width = arduino_width + mp2636_width + mpu_width + clearance * 4;
internal_height = max(arduino_height, mp2636_height, mpu_height, battery_height) + clearance * 2;

box_length = internal_length + wall_thickness * 2;
box_width = internal_width + wall_thickness * 2;
box_height = internal_height + wall_thickness;

// ============================================================================
// MAIN ASSEMBLY
// ============================================================================

// Choose what to render
render_bottom = true;
render_lid = true;
exploded_view = true;
explosion_distance = 30;

if (render_bottom) {
    enclosure_bottom();
}

if (render_lid) {
    translate([0, 0, exploded_view ? box_height + explosion_distance : 0])
        enclosure_lid();
}

// ============================================================================
// ENCLOSURE BOTTOM
// ============================================================================

module enclosure_bottom() {
    difference() {
        // Main box body
        rounded_box(box_length, box_width, box_height, 3);

        // Hollow out interior
        translate([wall_thickness, wall_thickness, wall_thickness])
            rounded_box(internal_length, internal_width, internal_height + 1, 2);

        // Micro-USB access for Arduino (front)
        translate([wall_thickness + clearance + arduino_length/2 - arduino_usb_width/2,
                   -1,
                   wall_thickness + clearance + arduino_height - arduino_usb_height])
            cube([arduino_usb_width, wall_thickness + 2, arduino_usb_height + 1]);

        // Micro-USB access for MP2636 (side)
        translate([-1,
                   wall_thickness + clearance + arduino_width + clearance + mp2636_width/2 - mp2636_usb_micro_width/2,
                   wall_thickness + clearance + mp2636_height - mp2636_usb_micro_height])
            cube([wall_thickness + 2, mp2636_usb_micro_width, mp2636_usb_micro_height + 1]);

        // USB-A access for MP2636 (side)
        translate([-1,
                   wall_thickness + clearance + arduino_width + clearance + mp2636_width/2 - mp2636_usb_a_width/2,
                   wall_thickness + clearance])
            cube([wall_thickness + 2, mp2636_usb_a_width, mp2636_usb_a_height]);

        // Lid screw holes (countersunk)
        corner_screws(countersink=true);
    }

    // Mounting posts for components
    component_mounting_posts();

    // Lid retention lip
    translate([wall_thickness + lid_lip, wall_thickness + lid_lip, box_height - wall_thickness])
        difference() {
            rounded_box(internal_length - lid_lip * 2, internal_width - lid_lip * 2, wall_thickness, 1.5);
            translate([0, 0, -0.5])
                rounded_box(internal_length - lid_lip * 2 - wall_thickness,
                           internal_width - lid_lip * 2 - wall_thickness,
                           wall_thickness + 1, 1);
        }
}

// ============================================================================
// ENCLOSURE LID
// ============================================================================

module enclosure_lid() {
    difference() {
        // Main lid plate
        rounded_box(box_length, box_width, wall_thickness, 3);

        // Screw holes
        corner_screws(countersink=false);

        // Ventilation slots for heat dissipation
        for (i = [0:4]) {
            translate([box_length/2 - 15 + i * 7, box_width/2 - 10, -0.5])
                cube([2, 20, wall_thickness + 1]);
        }
    }
}

// ============================================================================
// COMPONENT MOUNTING POSTS
// ============================================================================

module component_mounting_posts() {
    post_height = internal_height - clearance;

    // Arduino Nano mounting posts (4 corners)
    arduino_x = wall_thickness + clearance;
    arduino_y = wall_thickness + clearance;

    translate([arduino_x + 2, arduino_y + 2, wall_thickness])
        mounting_post(post_height, mounting_post_diameter, screw_hole_diameter);
    translate([arduino_x + arduino_length - 2, arduino_y + 2, wall_thickness])
        mounting_post(post_height, mounting_post_diameter, screw_hole_diameter);
    translate([arduino_x + 2, arduino_y + arduino_width - 2, wall_thickness])
        mounting_post(post_height, mounting_post_diameter, screw_hole_diameter);
    translate([arduino_x + arduino_length - 2, arduino_y + arduino_width - 2, wall_thickness])
        mounting_post(post_height, mounting_post_diameter, screw_hole_diameter);

    // MPU-6050 mounting posts (2 corners)
    mpu_x = wall_thickness + clearance;
    mpu_y = wall_thickness + clearance + arduino_width + clearance * 2;

    translate([mpu_x + 2, mpu_y + 2, wall_thickness])
        mounting_post(post_height, mounting_post_diameter, screw_hole_diameter);
    translate([mpu_x + mpu_length - 2, mpu_y + mpu_width - 2, wall_thickness])
        mounting_post(post_height, mounting_post_diameter, screw_hole_diameter);

    // MP2636 mounting posts (2 corners)
    mp2636_x = wall_thickness + clearance;
    mp2636_y = wall_thickness + clearance + arduino_width + clearance + mpu_width + clearance;

    translate([mp2636_x + 2, mp2636_y + 2, wall_thickness])
        mounting_post(post_height, mounting_post_diameter, screw_hole_diameter);
    translate([mp2636_x + mp2636_length - 2, mp2636_y + mp2636_width - 2, wall_thickness])
        mounting_post(post_height, mounting_post_diameter, screw_hole_diameter);
}

// ============================================================================
// HELPER MODULES
// ============================================================================

module mounting_post(height, diameter, hole_diameter) {
    difference() {
        cylinder(h=height, d=diameter, $fn=20);
        translate([0, 0, -0.5])
            cylinder(h=height + 1, d=hole_diameter, $fn=16);
    }
}

module corner_screws(countersink=false) {
    screw_inset = 4;

    positions = [
        [screw_inset, screw_inset],
        [box_length - screw_inset, screw_inset],
        [screw_inset, box_width - screw_inset],
        [box_length - screw_inset, box_width - screw_inset]
    ];

    for (pos = positions) {
        translate([pos[0], pos[1], -0.5]) {
            cylinder(h=wall_thickness + 1, d=screw_hole_diameter, $fn=16);
            if (countersink) {
                translate([0, 0, wall_thickness - 1])
                    cylinder(h=2, d1=screw_hole_diameter, d2=screw_hole_diameter + 2, $fn=16);
            }
        }
    }
}

module rounded_box(length, width, height, radius) {
    hull() {
        translate([radius, radius, 0])
            cylinder(h=height, r=radius, $fn=30);
        translate([length - radius, radius, 0])
            cylinder(h=height, r=radius, $fn=30);
        translate([radius, width - radius, 0])
            cylinder(h=height, r=radius, $fn=30);
        translate([length - radius, width - radius, 0])
            cylinder(h=height, r=radius, $fn=30);
    }
}

// ============================================================================
// NOTES
// ============================================================================

/*
 * ASSEMBLY INSTRUCTIONS:
 *
 * 1. Print both bottom and lid
 * 2. Use M2 screws (8-10mm length) for mounting components
 * 3. Use M2 screws (6-8mm length) for lid attachment
 * 4. Recommended print settings:
 *    - Layer height: 0.2mm
 *    - Infill: 20%
 *    - Supports: Not needed
 *    - Material: PLA or PETG
 *
 * MODIFICATIONS:
 *
 * To adjust dimensions, modify the component dimensions at the top.
 * To change clearances or wall thickness, modify the enclosure parameters.
 * To disable exploded view, set: exploded_view = false;
 */
