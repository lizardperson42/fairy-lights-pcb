/* [Rendering options] */
// Show placeholder PCB in OpenSCAD preview
show_pcb = true;
// Lid mounting method
lid_model = "cap"; // [cap, inner-fit]
// Conditional rendering
render = "case"; // [all, case, lid]


/* [Dimensions] */
// Height of the PCB mounting stand-offs between the bottom of the case and the PCB
standoff_height = 5;
// PCB thickness
pcb_thickness = 1.6;
// Bottom layer thickness
floor_height = 1.2;
// Case wall thickness
wall_thickness = 1.2;
// Space between the top of the PCB and the top of the case
headroom = 16.0;
// Lid edge thickness
lid_edge = 6.5;

/* [M2.5 screws] */
// Outer diameter for the insert
insert_M2_5_diameter = 3.27;
// Depth of the insert
insert_M2_5_depth = 3.75;

/* [Hidden] */
$fa=$preview ? 10 : 4;
$fs=0.2;
inner_height = floor_height + standoff_height + pcb_thickness + headroom;

module wall (thickness, height) {
    linear_extrude(height, convexity=10) {
        difference() {
            offset(r=thickness)
                children();
            children();
        }
    }
}

module bottom(thickness, height) {
    linear_extrude(height, convexity=3) {
        offset(r=thickness)
            children();
    }
}

module lid(thickness, height, edge) {
    linear_extrude(height, convexity=10) {
        offset(r=thickness)
            children();
    }
    translate([0,0,-edge])
    difference() {
        linear_extrude(edge, convexity=10) {
                offset(r=-0.2)
                children();
        }
        translate([0,0, -0.5])
         linear_extrude(edge+1, convexity=10) {
                offset(r=-1.2)
                children();
        }
    }
}


module box(wall_thick, bottom_layers, height) {
    if (render == "all" || render == "case") {
        translate([0,0, bottom_layers])
            wall(wall_thick, height) children();
        bottom(wall_thick, bottom_layers) children();
    }
    
    if (render == "all" || render == "lid") {
        translate([0, 0, height+bottom_layers+0.1])
        lid(wall_thick, bottom_layers, lid_model == "inner-fit" ? headroom-2.5: lid_edge)
            children();
    }
}

module mount(drill, space, height) {
    translate([0,0,height/2])
        difference() {
            cylinder(h=height, r=(space/2), center=true);
            cylinder(h=(height*2), r=(drill/2), center=true);
            
            translate([0, 0, height/2+0.01])
                children();
        }
        
}

module connector(min_x, min_y, max_x, max_y, height) {
    size_x = max_x - min_x;
    size_y = max_y - min_y;
    translate([(min_x + max_x)/2, (min_y + max_y)/2, height/2])
        cube([size_x, size_y, height], center=true);
}

module Cutout_Power_Jack_substract() {
    offset_out = 15;
    above_pcb = 6.5;
    // 9mm housing on the plug I measured + 0.5mm padding
    diameter = 9 + 1;
    length = 10;

    rotate([0, -90, 0])
    translate([above_pcb, 0, offset_out])
    cylinder(length, diameter/2, diameter/2, center = true);
}

module Cutout_SW_Tactile_SPST_substract() {
    above_pcb = 4;
    offset_out = 4;
    thickness = 3;
    offset_x = 4.5 / 2;
    width = 7.5;
    radius = 1;
    gap = 0.5;

    translate([offset_x, -offset_out, above_pcb])
    rotate([0, 90, -90])
    linear_extrude(height = thickness)
    difference() {
        offset(r = radius)
            square(width - 2 * radius, center = true);
        offset(r = radius - gap)
            square(width - 2 * radius, center = true);
    }
}
module Cutout_SW_Tactile_SPST_add() {
    above_pcb = 4;
    offset_out = 4.8;
    offset_x = 4.5 / 2;
    width = 9;

    thickness = 1;
    height = 1;
    length = width / sqrt(2);

    translate([offset_x, -offset_out, above_pcb])
    rotate([0, 90, 90]) 
    rotate([0, 0, 135]) {
        translate([-thickness/2, -thickness/2, 0])
            cube([thickness, thickness, height]);
        for (angle = [0 : 90 : 90]) {
            rotate([0, 0, angle])
            translate([0, -thickness/2, height]) {
                translate([-thickness/2, 0, 0])
                    cube([length - height, thickness, thickness]);
                multmatrix([[1, 0, 1, -thickness * sqrt(2) / 2],
                            [0, 1, 0, 0],
                            [0, 0, 1, -height],
                            [0, 0, 0, 1]])
                    cube([thickness * sqrt(2), thickness, height + thickness]);
                multmatrix([[1, 0, -1, length - thickness * sqrt(2) / 2],
                            [0, 1, 0, 0],
                            [0, 0, 1, -height],
                            [0, 0, 0, 1]])
                    cube([thickness * sqrt(2), thickness, height + thickness]);
            }
        }
    }
}

module Cutout_Screw_Terminal_1x03_substract() {
    offset_out = 10;
    depth = 5;

    width = 12;
    shift = -1;
    height = 3;

    rotate([0, 0, 0])
    translate([shift, offset_out, 0])
    cube([width, depth, height]);
}

module Cutout_TypeC_substract_D1() {
    // the measured values are a little too small, so 1mm padding
    width = 14.5 + 2;
    height = 7 + 2;

    // distance from motherboard to D1 board - half height of connector
    // (the D1's USB port is on the bottom side and the cutout is centered)
    connector_height = 3.2;
    above_pcb = 10.84 - connector_height / 2;

    // the pins are 25.4mm apart, and the USB port is centered
    offset_x = 12.7;

    offset_out = 27.5;
    depth = 10;

    translate([offset_x, offset_out + 1, above_pcb])
    rotate([0, 90, 90])
    union() {
        cube([height, width - height, depth], center = true);
        translate([0, (width - height) / 2, 0])
            cylinder(depth, height / 2, height / 2, center = true);
        translate([0, -(width - height) / 2, 0])
            cylinder(depth, height / 2, height / 2, center = true);
    }
}

module Cutout_Screw_Terminal_1x04_substract() {
    offset_out = 10;
    depth = 5;

    width = 17;
    shift = -1;
    height = 3;

    translate([shift, offset_out, 0])
    cube([width, depth, height]);
}

module Cutout_PinHeader_Power_substract() {
    // This is very bespoke.
    offset_out = 16.5;
    above_pcb = 2.5;
    offset_x = -2.5;

    width = 14.5;
    height = 8.5;
    length = 5;

    rotate([90, -90, 0])
    translate([above_pcb + height / 2, width / 2 + offset_x, offset_out])
    cube([height, width, length], center = true);
}

module pcb() {
    thickness = 1.6;

    color("#009900")
    difference() {
        linear_extrude(thickness) {
            polygon(points = [[60,63.25], [60.0400075,62.7416025], [60.159055,62.245685], [60.3542175,61.7745325], [60.620685,61.3396825], [60.9518925,60.9518925], [61.3396825,60.620685], [61.7745325,60.3542175], [62.245685,60.159055], [62.7416025,60.0400075], [63.25,60], [116.75,60], [117.2583975,60.0400075], [117.754315,60.159055], [118.2254675,60.3542175], [118.6603175,60.620685], [119.0481075,60.9518925], [119.379315,61.3396825], [119.6457825,61.7745325], [119.840945,62.245685], [119.9599925,62.7416025], [120,63.25], [120,116.75], [119.9599925,117.2583975], [119.840945,117.754315], [119.6457825,118.2254675], [119.379315,118.6603175], [119.0481075,119.0481075], [118.6603175,119.379315], [118.2254675,119.6457825], [117.754315,119.840945], [117.2583975,119.9599925], [116.75,120], [63.25,120], [62.7416025,119.9599925], [62.245685,119.840945], [61.7745325,119.6457825], [61.3396825,119.379315], [60.9518925,119.0481075], [60.620685,118.6603175], [60.3542175,118.2254675], [60.159055,117.754315], [60.0400075,117.2583975], [60,116.75], [60,63.25]]);
        }
    translate([116.75, 116.75, -1])
        cylinder(thickness+2, 1.0999999999999943, 1.0999999999999943);
    translate([116.75, 63.25, -1])
        cylinder(thickness+2, 1.0999999999999943, 1.0999999999999943);
    translate([63.25, 63.25, -1])
        cylinder(thickness+2, 1.0999999999999943, 1.0999999999999943);
    translate([63.25, 116.75, -1])
        cylinder(thickness+2, 1.0999999999999943, 1.0999999999999943);
    }
}

module case_outline() {
    polygon(points = [[122,116.75], [121.9353725,117.5712575], [121.743065,118.372355], [121.4278025,119.1334475], [120.997355,119.8358975], [120.4623275,120.4623275], [119.8358975,120.997355], [119.1334475,121.4278025], [118.372355,121.743065], [117.5712575,121.9353725], [116.75,122], [63.25,122], [62.4287425,121.9353725], [61.627645,121.743065], [60.8665525,121.4278025], [60.1641025,120.997355], [59.5376725,120.4623275], [59.002645,119.8358975], [58.5721975,119.1334475], [58.256935,118.372355], [58.0646275,117.5712575], [58,116.75], [58,63.25], [58.0646275,62.4287425], [58.256935,61.627645], [58.5721975,60.8665525], [59.002645,60.1641025], [59.5376725,59.5376725], [60.1641025,59.002645], [60.8665525,58.5721975], [61.627645,58.256935], [62.4287425,58.0646275], [63.25,58], [116.75,58], [117.5712575,58.0646275], [118.372355,58.256935], [119.1334475,58.5721975], [119.8358975,59.002645], [120.4623275,59.5376725], [120.997355,60.1641025], [121.4278025,60.8665525], [121.743065,61.627645], [121.9353725,62.4287425], [122,63.25], [122,116.75]]);
}

module Insert_M2_5() {
    translate([0, 0, -insert_M2_5_depth])
        cylinder(insert_M2_5_depth, insert_M2_5_diameter/2, insert_M2_5_diameter/2);
    translate([0, 0, -0.3])
        cylinder(0.3, insert_M2_5_diameter/2, insert_M2_5_diameter/2+0.3);
}

rotate([render == "lid" ? 180 : 0, 0, 0])
scale([1, -1, 1])
translate([-90.0, -90.0, 0]) {
    pcb_top = floor_height + standoff_height + pcb_thickness;

    difference() {
        box(wall_thickness, floor_height, inner_height) {
            case_outline();
        }

    // Substract: Power_Jack
    translate([74, 106.5, pcb_top])
        Cutout_Power_Jack_substract();

    // Substract: Generic push-button switch, two contact pins and shield pin(s)
    translate([99.5, 117.2441, pcb_top])
    rotate([0, 0, -180])
        Cutout_SW_Tactile_SPST_substract();

    // Substract: LED strand connector (WS2812)
    translate([108.5, 81.5, pcb_top])
    rotate([0, 0, -90])
        Cutout_Screw_Terminal_1x03_substract();

    // Substract: 32-bit microcontroller module with WiFi
    translate([86.25, 75.5, pcb_top])
    rotate([0, 0, 90])
        Cutout_TypeC_substract_D1();

    // Substract: LED strand connector (SPI)
    translate([108.5, 103, pcb_top])
    rotate([0, 0, -90])
        Cutout_Screw_Terminal_1x04_substract();

    // Substract: Generic push-button switch, two contact pins and shield pin(s)
    translate([109.25, 117.25, pcb_top])
    rotate([0, 0, -180])
        Cutout_SW_Tactile_SPST_substract();

    // Substract: 1x DIP Switch, Single Pole Single Throw (SPST) switch, small symbol
    translate([79.5, 106.5, pcb_top])
    rotate([0, 0, -180])
        Cutout_PinHeader_Power_substract();

    }

    if (show_pcb && $preview) {
        translate([0, 0, floor_height + standoff_height])
            pcb();
    }

    if (render == "all" || render == "case") {
        // H3 [('M2.5', 2.5)]
        translate([116.75, 116.75, floor_height])
        mount(2.2, 4.9, standoff_height)
            Insert_M2_5();
        // H2 [('M2.5', 2.5)]
        translate([116.75, 63.25, floor_height])
        mount(2.2, 4.9, standoff_height)
            Insert_M2_5();
        // H1 [('M2.5', 2.5)]
        translate([63.25, 63.25, floor_height])
        mount(2.2, 4.9, standoff_height)
            Insert_M2_5();
        // H4 [('M2.5', 2.5)]
        translate([63.25, 116.75, floor_height])
        mount(2.2, 4.9, standoff_height)
            Insert_M2_5();
        // Generic push-button switch, two contact pins and shield pin(s)
        translate([99.5, 117.2441, pcb_top])
        rotate([0, 0, -180])
            Cutout_SW_Tactile_SPST_add();

        // Generic push-button switch, two contact pins and shield pin(s)
        translate([109.25, 117.25, pcb_top])
        rotate([0, 0, -180])
            Cutout_SW_Tactile_SPST_add();

    }
}
