zff = 1/64;
drain_r = 10;
drain_pipe_or = 26.6/2;
drain_pipe_ir = 21.6/2;
thickness = 3.1;

// This is the length of one bead and one bit of string.
// 0-0-0-0-0-0-0-...
// | | <-- This distance
bead_chain_straight_pitch = 60.6/10;
bead_r = 4.36/2; // The radius of a bead
bead_cord_r = 1.61/2; // The radius of the cord
bead_chain_extra_string = 0.5; // This extends the string segments a bit so they properly mesh with the next bead.

bead_clearance = 0.2; // The clearance around a bead to let it move smoothly. Includes the laser kerf.

max_wt = (drain_r*2 - bead_r*4)/2;
wt = 4;
shaft_r = 1.5;

if (wt > max_wt) {
    // This isn't valid openscad, but it does cause an error in console, so... success?
    error("wt is too big");
}

pump_length = 530;

module strip () {
    hull () {
        cylinder(r=wt/2, h=thickness, $fn=16);
        translate([pump_length,0,0]) cylinder(r=wt/2, h=thickness, $fn=16);
    }
}

module cap() {
    hull () {
        strip();
        translate([0,wt+bead_r*2+bead_clearance,0]) strip();
    }
}


module bead_chain_segment() {
    sphere(r=bead_r, $fn=16);
    rotate([90,0,0]) cylinder(r=bead_cord_r, h=bead_chain_straight_pitch-bead_r+bead_chain_extra_string, $fn=16);
}
module vertical_bead_chain_segment() {
    cylinder(r=bead_r, h=100,$fn=16);
    translate([-bead_cord_r,-(bead_chain_straight_pitch-bead_r+bead_chain_extra_string),0]) cube([bead_cord_r*2,bead_chain_straight_pitch-bead_r+bead_chain_extra_string,100]);
}

bead_n = 16;
bead_chain_r = bead_chain_straight_pitch/tan(360/bead_n);

module bead_chain_gear_solid() {
    difference() {
        cylinder(r=bead_chain_r, h=thickness);
        scale([1,1,100]) union() {
            for (i = [0:360/bead_n:360]) {
                rotate([0,0,i]) translate([bead_chain_r,0,0]) rotate([0,0,(-360/bead_n)/2]) bead_chain_segment();
                // rotate([0,0,i]) translate([bead_chain_r,0,0]) rotate([0,0,(-360/bead_n)/2]) vertical_bead_chain_segment();
            }
        }
        translate([0,0,-50]) cylinder(r=shaft_r, h=100, $fn=32);
    }
}
module bead_chain_gear_flange() {
    cylinder(r=bead_chain_r+bead_r/2, h=thickness);
}

drain_protrusion = 5;

module lasercut_stalk() {
    cap();
    translate([0,0,thickness]) strip();
    translate([0,0,thickness*2]) strip();
    translate([0,wt+bead_r*2+bead_clearance,thickness]) strip();
    translate([0,wt+bead_r*2+bead_clearance,thickness*2]) strip();
    translate([0,0,thickness*3]) cap();
}

pump_body_r = bead_chain_r+bead_r;
// This ensures the stackup is an integer thickness of acrylic.
pump_face_plate_z_ideal = (drain_pipe_or+wt)*2;
pump_face_plate_z = ceil(pump_face_plate_z_ideal/thickness)*thickness;

// This is the part through which the drain pipe protrudes
module pump_face_plate() {
    difference() {
        translate([0,-(bead_chain_r+bead_r+wt),0]) cube([thickness, (bead_chain_r+bead_r+wt)*2, pump_face_plate_z]);
        translate([-drain_protrusion,0,pump_face_plate_z/2]) rotate([0,90,0]) cylinder(r=drain_pipe_or, h=100, $fn=32);
    }
}

// This has a slightly smaller hole in it to block the drain pipe from coming in any further.
module pump_face_plate_blocker(pipe_hole_r, offset) {
    difference() {
        translate([0,-(bead_chain_r+bead_r+wt),0]) cube([thickness, (bead_chain_r+bead_r+wt)*2, pump_face_plate_z]);
        translate([-zff,0,pump_face_plate_z/2]) rotate([0,90,0]) {
        difference() {
            cylinder(r=drain_pipe_ir, h=100, $fn=32);
            // #translate([-50,-drain_pipe_ir,0]) cube([100,drain_pipe_ir-bead_chain_tube_or,100]);
            translate([0,offset,0]) cylinder(r=pipe_hole_r+wt, h=100, $fn=32);
            // Awkwardly fillet the sharp corner around the bead chain pipe holder
            translate([pipe_hole_r+wt,offset+pipe_hole_r/2,0]) difference() {
                rotate([0,0,-30]) translate([-wt,-wt/2,0]) cube([wt*2,wt,thickness]);
            }
            translate([-(pipe_hole_r+wt),offset+pipe_hole_r/2,0]) difference() {
                rotate([0,0,30]) translate([-wt,-wt/2,0]) cube([wt*2,wt,thickness]);
            }
        }
        translate([0,offset,0]) cylinder(r=pipe_hole_r,h=100, $fn=16);
        }
    }
}

// This is the top and bottom parts of the pump body.
module pump_body_base() {
    translate([-thickness/2,0,0]) hull() {
        translate([0,0,thickness/2]) cube([thickness, (bead_chain_r+bead_r+wt)*2, thickness],center=true);
        translate([-(bead_chain_r+bead_r+wt)-drain_protrusion,0,0]) cylinder(r=bead_chain_r+bead_r+wt,h=thickness);
    }
}

// These parts are stacked up to form the walls of the body.
module pump_body_wall() {
    difference() {
        pump_body_base();
        hull() {
            translate([-(bead_chain_r+bead_r+wt)-drain_protrusion-thickness/2,0,0]) cylinder(r=bead_chain_r+bead_r,h=thickness);
            translate([0,0,thickness/2]) cube([thickness, (bead_chain_r+bead_r)*2, thickness],center=true);
        }
    }
}

bead_chain_tube_or = 6.3/2;
bead_chain_tube_ir = bead_chain_tube_or-0.77;
module bead_chain_tube() {
    rotate([0,90,0]) difference() {
        cylinder(r=bead_chain_tube_or, h=600+zff*2, $fn=16);
        translate([0,0,-zff]) cylinder(r=bead_chain_tube_ir, h=600, $fn=16);
    }
}

module pump_face_plate_blocker_inner() {
    pump_face_plate_blocker(bead_chain_tube_ir,-(drain_pipe_ir-bead_chain_tube_or));
}
module pump_face_plate_blocker_outer() {
    pump_face_plate_blocker(bead_chain_tube_or,-(drain_pipe_ir-bead_chain_tube_or));
}

module assembled() {
    // translate([0,0, thickness*2]) rotate([0,90,0]) #cylinder(r=drain_r, h=pump_length, $fn=16);
    // translate([wt/2+pump_body_r,wt/2-(wt+bead_r*2+bead_clearance)/2+-bead_r,0]) lasercut_stalk();
    translate([-(bead_chain_r+bead_r+wt)-drain_protrusion-thickness/2,0,thickness*4]) render() bead_chain_gear_flange();
    translate([-(bead_chain_r+bead_r+wt)-drain_protrusion-thickness/2,0,thickness*5]) render() bead_chain_gear_solid();
    translate([-(bead_chain_r+bead_r+wt)-drain_protrusion-thickness/2,0,thickness*6]) render() bead_chain_gear_solid();
    translate([-(bead_chain_r+bead_r+wt)-drain_protrusion-thickness/2,0,thickness*7]) render() bead_chain_gear_flange();
    // translate([0,0,thickness*2]) render() bead_chain_gear_solid();
    pump_body_base();
    translate([0,0,pump_face_plate_z-thickness]) pump_body_base();
    translate([thickness*3,0,0]) pump_face_plate();
    translate([thickness*2,0,0]) pump_face_plate();
    pump_face_plate_blocker_inner();
    translate([thickness,0,0]) pump_face_plate_blocker_outer();
    translate([0,0,thickness]) pump_body_wall();
    // translate([0,-(drain_pipe_ir-bead_chain_tube_or),pump_face_plate_z/2]) bead_chain_tube();
    // vertical_bead_chain_segment();
    // bead_chain_gear(1,0);
}

// projection() rotate([0,90,0]) pump_face_plate_blocker(bead_chain_tube_ir,-(drain_pipe_ir-bead_chain_tube_or));
// projection() rotate([0,90,0]) pump_face_plate_blocker(bead_chain_tube_or,-(drain_pipe_ir-bead_chain_tube_or));

batch_export=true;

part_revision_number = 1;
// These are load-bearing comments. The make script awks this file for
// lines between these markers to determine what it needs to render to a file.
// PARTSMARKERSTART
export_bead_chain_gear_flange = false;
export_bead_chain_gear_solid = false;
export_pump_body_base = false;
export_pump_face_plate = false;
export_pump_face_plate_blocker_inner = false;
export_pump_face_plate_blocker_outer = false;
export_pump_body_wall = false;
// PARTSMARKEREND

if (batch_export) {
    if (export_bead_chain_gear_flange) projection() bead_chain_gear_flange();
    if (export_bead_chain_gear_solid) projection() bead_chain_gear_solid();
    if (export_pump_body_base) projection() pump_body_base();
    if (export_pump_face_plate) projection() rotate([0,90,0]) pump_face_plate();
    if (export_pump_face_plate_blocker_inner) projection() rotate([0,90,0]) pump_face_plate_blocker_inner();
    if (export_pump_face_plate_blocker_outer) projection() rotate([0,90,0]) pump_face_plate_blocker_outer();
    if (export_pump_body_wall) projection() pump_body_wall();

} else {
    assembled();
}