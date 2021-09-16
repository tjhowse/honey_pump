// Sorry for mixing openscad and freecad in one project.
// I started this project partly to learn freecad, but when I found
// myself needing to design the motor mount I didn't have the mental
// energy to re-inveigl myself into freecad, so I fell back on
// comfortable old openscad.


gearbox_r = 36.8/2; // The OD of the gearbox housing of the motor/gearbox combo I'm using.
gearbox_z = 25; // The length of the gearbox housing.
gearbox_out_r = 12.04/2; // A bearing enclosure that protrudes from the end of the gearbox.
gearbox_out_z = 5.62; // The length of the bearing holder protrusion
gearbox_out_edge_offset = 19.35; // The measured distance between the edge of the gearbox and the edge of the protrusion
gearbox_out_centre_offset = gearbox_out_edge_offset - (gearbox_r - gearbox_out_r); // Calculate the offset from the centre of the protrusion.
pump_r = 50/2; // The OD of the pump main housing, from the freecad file.
pump_z = gearbox_z+gearbox_out_z; // Limit the length of the mount to the size of the gearbox on the motor.
pump_slice_offset = 17.2; // From the freecad file, determines where the pump attachment ring is chopped off.

wt = 3; // Wall thickness.
clearance = 0.1;

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

motor_mount();

