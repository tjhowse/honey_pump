use <CustomizablePrintableAuger.scad>

shaft_r = 3/2; // The rod down the centre of the auger.
auger_r = 20/2; // The radius of the auger.
auger_l = 100; // The length of the auger.
wt = 1.5; // Wall thickness
// $fn=24;
flightThickness = 2;
supportThickness = 0.2;
// supportThickness = 0;
turnPerHeight = auger_l/10;
intersection() {
        translate([0,0,-flightThickness]) difference () {

        auger(r1=shaft_r+wt, r2=auger_r, h=auger_l,
                turns=turnPerHeight, multiStart=1, flightThickness = flightThickness,
                overhangAngle=0, supportThickness=supportThickness);
                // overhangAngle=0, supportThickness=0.2);
        cylinder(r=shaft_r, h=auger_l, $fn=36);
    }
    cylinder(r=auger_r+supportThickness, h=auger_l-flightThickness*2, $fn=36);
}

// Increase minimum print speed during cooling from 10 to 40.


// %cylinder(r=auger_r,h=100);