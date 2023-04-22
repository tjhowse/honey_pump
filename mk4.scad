include <mk3.scad>

body_height = (drain_pipe_or+wt)*2;
// body_height = thickness;
sprocket_r = bead_chain_r+bead_r;
// This is the length of the sleve/socket into which the drain pipe sockets.
drain_socket_shelf_x = wt;
drain_socket_x = 15+drain_socket_shelf_x;
bead_tube_socket_shelf = wt;
bead_tube_socket_x = 5+bead_tube_socket_shelf;
bead_chain_tube_socket_x = 6;
wt = 3;


module drain_pipe_and_shelf(bead_pipe=false) {
    if (bead_pipe) {
        translate([0,-drain_pipe_ir+bead_chain_tube_or,bead_tube_socket_shelf]) cylinder(r=bead_chain_tube_or, h=100, $fn=16);
        translate([0,-drain_pipe_ir+bead_chain_tube_or,-1]) cylinder(r=bead_chain_tube_ir, h=100, $fn=16);
        translate([0,0,drain_socket_shelf_x+bead_tube_socket_x]) cylinder(r=drain_pipe_or, h=100);
        // This is the passage for the honey from the frame into the pump
        hole_height = drain_pipe_ir*2-2*bead_chain_tube_or-(drain_pipe_or-drain_pipe_ir);
        intersection() {
            translate([0,0,-1]) cylinder(r=drain_pipe_ir, h=100);
            union() {
                translate([0,drain_pipe_ir-hole_height/2,50-1]) cube([drain_pipe_ir*2,hole_height,100], center=true);
                // #cylinder(r=3, h=100, $fn=16);
            }
        }
    } else {
        translate([0,0,drain_socket_shelf_x]) cylinder(r=drain_pipe_or, h=100);
        translate([0,0,-1]) cylinder(r=drain_pipe_ir, h=100);
    }
}

// !drain_pipe_and_shelf(true);

bolt_r=1.5;

module bolt_hole() {
    difference () {
        cylinder(r=wt+bolt_r, h=body_height, $fn=16);
        cylinder(r=bolt_r, h=body_height, $fn=16);
    }
}

module printable() {
    difference () {
        union() {
            hull() {
                // This little 90 rotation of the cylinder is so the facets land on the y axis.
                rotate([0,0,90]) cylinder(r=sprocket_r+wt,h=body_height);
                translate([sprocket_r,-(sprocket_r+wt),0])
                    cube([wt+drain_pipe_or+wt+drain_socket_x+bead_tube_socket_x, (sprocket_r+wt)*2, body_height]);
            }
            translate([0,sprocket_r+wt,0]) cube([(drain_pipe_or+wt)*2, drain_socket_x-wt, body_height]);
        }
        // This is the cutout for the inside of the body
        translate([0,0,-zff+wt]) hull() {
            // This little 90 rotation of the cylinder is so the facets land on the y axis.
            rotate([0,0,90]) cylinder(r=sprocket_r,h=body_height+zff*2-2*wt);
            translate([sprocket_r,-sprocket_r,0])
                cube([wt+drain_pipe_or, (sprocket_r)*2, body_height]);
        }
        // This is the cutout for the shaft
        cylinder(r=shaft_r, h=body_height, $fn=64);

        translate([sprocket_r+wt,drain_pipe_or,body_height/2]) rotate([-90,0,0]) drain_pipe_and_shelf();
        translate([sprocket_r+wt+drain_pipe_or,0,body_height/2]) rotate([0,90,0]) drain_pipe_and_shelf(true);
    }
    translate([-bolt_r, drain_pipe_or+wt+bolt_r,0]) bolt_hole();
    translate([-bolt_r, -(drain_pipe_or+wt+bolt_r),0]) bolt_hole();
    translate([sprocket_r+wt+drain_pipe_or+(drain_socket_x+bead_tube_socket_x)/2+wt, drain_pipe_or+wt+bolt_r,0]) bolt_hole();
    translate([sprocket_r+wt+drain_pipe_or+(drain_socket_x+bead_tube_socket_x)/2+wt, -(drain_pipe_or+wt+bolt_r),0]) bolt_hole();
}

intersection() {
    printable();
    translate([0,0,-500+body_height/2]) cube([1000,1000,1000], center=true);
}

// pump_face_plate_blocker_inner();
//     translate([thickness,0,0]) pump_face_plate_blocker_outer();