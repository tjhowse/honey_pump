include <mk3.scad>

body_height = (drain_pipe_or+wt)*2;
// body_height = thickness;
sprocket_r = bead_chain_r+bead_r;
// This is the length of the sleve/socket into which the drain pipe sockets.
drain_socket_x = 15;
bead_chain_tube_socket_x = 6;



module printable() {
    difference () {
        union() {
            hull() {
                // This little 90 rotation of the cylinder is so the facets land on the y axis.
                rotate([0,0,90]) cylinder(r=sprocket_r+wt,h=body_height);
                translate([sprocket_r,-(sprocket_r+wt),0])
                    cube([(drain_pipe_or+wt)*2-sprocket_r, (sprocket_r+wt)*2, body_height]);
            }
            translate([0,sprocket_r+wt,0]) cube([(drain_pipe_or+wt)*2, drain_socket_x-wt, body_height]);
            // translate([0,-(drain_pipe_or+wt),0]) #cube([(drain_pipe_or+wt)*2, (sprocket_r+wt)*2, body_height]);
        }
        // This is the cutout for the inside of the body
        translate([0,0,-zff+wt]) hull() {
            // This little 90 rotation of the cylinder is so the facets land on the y axis.
            rotate([0,0,90]) cylinder(r=sprocket_r,h=body_height+zff*2-2*wt);
            translate([sprocket_r,0,(body_height+zff*2-2*wt)/2])
                translate([-0.5,0,0]) cube([1, (sprocket_r)*2, body_height+zff*2-2*wt],center=true);
        }
        // translate([-(bead_chain_r+bead_r+wt)-drain_protrusion,0,0]) cylinder(r=shaft_r,h=body_height, $fn=32);

        translate([sprocket_r+wt,0,body_height/2]) rotate([-90,0,0]) cylinder(r=drain_pipe_or, h=100);
        translate([sprocket_r-1,0,body_height/2]) rotate([0,90,0]) cylinder(r=drain_pipe_or, h=100);
    }
}

!printable();