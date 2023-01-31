zff = 1/32;
drain_r = 10;
drain_pipe_od_r = 26.6/2;
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


module assembled() {
    cap();
    translate([0,0,thickness]) strip();
    translate([0,0,thickness*2]) strip();
    translate([0,wt+bead_r*2+bead_clearance,thickness]) strip();
    translate([0,wt+bead_r*2+bead_clearance,thickness*2]) strip();
    translate([0,0,thickness*3]) cap();
}

pump_body_r = bead_chain_r+bead_r;
module pump_body() {
    cylinder(r=bead_chain_r+bead_r+wt,h=thickness);
    difference() {
        translate([0,0,-zff+thickness]) cylinder(r=bead_chain_r+bead_r+wt,h=thickness*2);
        translate([0,0,-zff+thickness]) cylinder(r=pump_body_r,h=thickness*2+2*zff);
    }
    translate([0,0,-zff+thickness*3]) cylinder(r=bead_chain_r+bead_r+wt,h=thickness);
    #translate([0,0,0]) difference() {
        hull() {
            translate([(bead_chain_r+bead_r+wt),-(bead_chain_r+bead_r+wt),0]) cube([thickness, (bead_chain_r+bead_r+wt)*2, thickness*4]);
            cylinder(r=bead_chain_r+bead_r+wt,h=thickness*4);
        }
        translate([0,0, thickness*2]) rotate([0,90,0]) cylinder(r=drain_r, h=pump_length, $fn=16);
    }
}

// translate([0,0, thickness*2]) rotate([0,90,0]) #cylinder(r=drain_r, h=pump_length, $fn=16);
translate([wt/2+pump_body_r,wt/2-(wt+bead_r*2+bead_clearance)/2+-bead_r,0]) assembled();
translate([0,0,thickness]) render() bead_chain_gear_solid();
translate([0,0,thickness*2]) render() bead_chain_gear_solid();
pump_body();
// vertical_bead_chain_segment();
// bead_chain_gear(1,0);