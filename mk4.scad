include <mk3.scad>

// body_height = (drain_pipe_or+wt)*2;
body_height = thickness;
sprocket_r = bead_chain_r+bead_r;
// This is the length of the sleve/socket into which the drain pipe sockets.
drain_socket_x = 10;


module printable() {
    difference () {
        hull() {
            cylinder(r=sprocket_r+wt,h=body_height);
            translate([sprocket_r+wt+drain_socket_x,0,body_height/2])
                translate([-0.5,0,0]) cube([1, (sprocket_r+wt)*2, body_height],center=true);
        }
        hull() {
            cylinder(r=sprocket_r,h=body_height);
            translate([sprocket_r+drain_socket_x,0,body_height/2])
                translate([-0.5,0,0]) cube([1, (sprocket_r)*2, body_height],center=true);
        }
        // translate([-(bead_chain_r+bead_r+wt)-drain_protrusion,0,0]) cylinder(r=shaft_r,h=body_height, $fn=32);
    }
}
!printable();