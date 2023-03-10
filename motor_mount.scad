// Sorry for mixing openscad and freecad in one project.
// I started this project partly to learn freecad, but when I found
// myself needing to design the motor mount I didn't have the mental
// energy to re-inveigl myself into freecad, so I fell back on
// comfortable old openscad.

use <gear.scad>

gearbox_r = 36.8/2; // The OD of the gearbox housing of the motor/gearbox combo I'm using.
gearbox_z = 25; // The length of the gearbox housing.
gearbox_out_r = 12.04/2; // A bearing enclosure that protrudes from the end of the gearbox.
gearbox_out_z = 5.62; // The length of the bearing holder protrusion
gearbox_out_edge_offset = 19.35; // The measured distance between the edge of the gearbox and the edge of the protrusion
gearbox_out_centre_offset = gearbox_out_edge_offset - (gearbox_r - gearbox_out_r); // Calculate the offset from the centre of the protrusion.
pump_r = 50/2; // The OD of the pump main housing, from the freecad file.
pump_z = gearbox_z+gearbox_out_z; // Limit the length of the mount to the size of the gearbox on the motor.
pump_slice_offset = 17.2; // From the freecad file, determines where the pump attachment ring is chopped off.
$fn = 32;

wt = 4; // Wall thickness.
clearance = 0.1;
grub_screw_r = 1.6;

shaft_r = 12.5/2;

shaft_offset = pump_r+wt+gearbox_r-gearbox_out_centre_offset;
tooth_count = 20;
circular_pitch = shaft_offset / tooth_count * 180;
gear_thickness = 15;
// shaft_offset  =  number_of_teeth * outside_circular_pitch / 180;


module gearbox() {
    translate([0,0,gearbox_out_z]) cylinder(r=gearbox_r+clearance, h = gearbox_z);
    translate([gearbox_out_centre_offset,0,0]) cylinder(r=gearbox_out_r+clearance, h = gearbox_out_z);
}

module gearbox_shell() {
    difference() {
        cylinder(r=gearbox_r+wt, h = gearbox_z+gearbox_out_z);
        gearbox();
    }
}

module pump() {
    cylinder(r=pump_r+clearance, h = pump_z);
}

module pump_shell() {
    difference() {
        cylinder(r=pump_r+wt, h = pump_z);
        pump();
        translate([pump_slice_offset,-50,0]) cube([100,100,100]);
    }
}

module motor_mount() {
    translate([-gearbox_r-wt/2,0,0]) gearbox_shell();
    translate([pump_r+wt/2,0,0]) pump_shell();
}

module drive_gear() {
    difference() {
        gear (circular_pitch=circular_pitch,
            number_of_teeth=tooth_count,
            gear_thickness = gear_thickness,
            rim_thickness = gear_thickness,
            bore_diameter=12.5);
        rotate([0,0,180/tooth_count]) {
            translate([0,0,gear_thickness/2]) rotate([90,0,0]) cylinder(r=grub_screw_r, h=100);
            translate([0,-shaft_offset/8-shaft_r,gear_thickness/2]) #cube([10,3,gear_thickness], center=true);
        }
    }
}

module driven_gear() {
    drive_gear();
}

// This fits around the outflow nozzle and provides mounting loops for a strap passing over the motor
// mount to hold it against the pump body.
strap_x = 20;
strap_y = wt;
// +0.5 for ring clearance.
pump_drain_r = 24/2+0.5;
module strap_ring() {
    ring_x = (pump_drain_r+wt)*2;
    ring_y = pump_drain_r*2+wt*4+strap_y*2;
    difference () {
        cube([ring_x, ring_y, wt]);
        translate([ring_x/2,strap_y/2+wt,0]) cube([strap_x, strap_y, 100],center=true);
        translate([ring_x/2, ring_y/2, 0]) cylinder(r=pump_drain_r, h = 100);
        translate([ring_x/2,ring_y-strap_y/2-wt,0]) cube([strap_x, strap_y, 100],center=true);
    }
}

// driven_gear();
strap_ring();


// motor_mount();

// translate([0,0,-15]) {
//     translate([pump_r+wt/2,0,0]) rotate([0,0,180/tooth_count]) driven_gear();
//     translate([-gearbox_r+gearbox_out_centre_offset-wt/2,0,0]) drive_gear();
// }