
shaft_r = 3/2; // The rod down the centre of the auger.
auger_r = 19/2; // The radius of the auger.
pitch = 40;
// pitch = 0;
auger_l = pitch*1; // The length of the auger.
// auger_l = 2; // The length of the auger.
// slice_count = 100;
slice_count = 1000;

wt = 1.5; // Wall thickness
// fin_slice_size = wt*5;
fin_slice_size = (shaft_r+wt)*2;
$fn=24;

module fins() {
    linear_extrude(
                    height=auger_l
                    ,twist=auger_l*pitch
                    ,slices=slice_count
                    ,convexity=10
                    ) {
        translate([-fin_slice_size/2,0,0]) square([fin_slice_size,auger_r]);
    }
}

module auger() {

    intersection() {
        cylinder(r=auger_r, h=auger_l);
        difference () {
            union() {
                cylinder(r=shaft_r+wt, h=auger_l);
                fins();
                // translate([0,0,wt/2]) fins();
            }
            cylinder(r=shaft_r, h=auger_l);
        }
    }

}

intersection() {
    translate([0,-50,0]) cube([100,100,100]);
    rotate([0,90,0]) auger();
}
// intersection() {
//     translate([-100,-50,0]) cube([100,100,100]);
//     rotate([0,-90,0]) auger();
// }
// auger();
