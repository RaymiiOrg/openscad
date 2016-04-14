// Dwergsein
// by Remy van Elst
// https://raymii.org
// license (except the triangle and arc): GNU GPLv3 or later.
// measured in centimeters.

/*
Triangles.scad
 Author: Tim Koopman
 https://github.com/tkoopman/Delta-Diamond/blob/master/OpenSCAD/Triangles.scad

         angleCA
           /|\
        a / H \ c
         /  |  \
 angleAB ------- angleBC
            b

Standard Parameters
	center: true/false
		If true same as centerXYZ = [true, true, true]

	centerXYZ: Vector of 3 true/false values [CenterX, CenterY, CenterZ]
		center must be left undef

	height: The 3D height of the Triangle. Ignored if heights defined

	heights: Vector of 3 height values heights @ [angleAB, angleBC, angleCA]
		If CenterZ is true each height will be centered individually, this means
		the shape will be different depending on CenterZ. Most times you will want
		CenterZ to be true to get the shape most people want.
*/

/* 
Triangle
	a: Length of side a
	b: Length of side b
	angle: angle at point angleAB
*/
module Triangle(
			a, b, angle, height=1, heights=undef,
			center=undef, centerXYZ=[false,false,false])
{
	// Calculate Heights at each point
	heightAB = ((heights==undef) ? height : heights[0])/2;
	heightBC = ((heights==undef) ? height : heights[1])/2;
	heightCA = ((heights==undef) ? height : heights[2])/2;
	centerZ = (center || (center==undef && centerXYZ[2]))?0:max(heightAB,heightBC,heightCA);

	// Calculate Offsets for centering
	offsetX = (center || (center==undef && centerXYZ[0]))?((cos(angle)*a)+b)/3:0;
	offsetY = (center || (center==undef && centerXYZ[1]))?(sin(angle)*a)/3:0;
	
	pointAB1 = [-offsetX,-offsetY, centerZ-heightAB];
	pointAB2 = [-offsetX,-offsetY, centerZ+heightAB];
	pointBC1 = [b-offsetX,-offsetY, centerZ-heightBC];
	pointBC2 = [b-offsetX,-offsetY, centerZ+heightBC];
	pointCA1 = [(cos(angle)*a)-offsetX,(sin(angle)*a)-offsetY, centerZ-heightCA];
	pointCA2 = [(cos(angle)*a)-offsetX,(sin(angle)*a)-offsetY, centerZ+heightCA];

	polyhedron(
		points=[	pointAB1, pointBC1, pointCA1,
					pointAB2, pointBC2, pointCA2 ],
		faces=[	
			[0, 1, 2],
			[3, 5, 4],
			[0, 3, 1],
			[1, 3, 4],
			[1, 4, 2],
			[2, 4, 5],
			[2, 5, 0],
			[0, 5, 3] ] );
}

/*
Isosceles Triangle
	Exactly 2 of the following paramaters must be defined.
	If all 3 defined H will be ignored.
	b: length of side b
	angle: angle at points angleAB & angleBC.
*/
module Isosceles_Triangle(
			b, angle, H=undef, height=1, heights=undef,
			center=undef, centerXYZ=[true, false, false])
{
	valid = 	(angle!=undef)?((angle < 90) && (b!=undef||H!=undef)) : (b!=undef&&H!=undef);
	ANGLE = (angle!=undef) ? angle : atan(H / (b/2));
	a = (b==undef)?(H/sin((180-(angle*2))/2)) : 
		 (b / cos(ANGLE))/2;
	B = (b==undef)? (cos(angle)*a)*2:b;
	if (valid)
	{
		Triangle(a=a, b=B, angle=ANGLE, height=height, heights=heights,
					center=center, centerXYZ=centerXYZ);
	} else {
		echo("Invalid Isosceles_Triangle. Must specify any 2 of b, angle and H, and if angle used angle must be less than 90");
	}
}

/*
Right Angled Triangle
	Create a Right Angled Triangle where the hypotenuse will be calculated.

       |\
      a| \
       |  \
       ----
         b
	a: length of side a
	b: length of side b
*/
module Right_Angled_Triangle(
			a, b, height=1, heights=undef,
			center=undef, centerXYZ=[false, false, false])
{
	Triangle(a=a, b=b, angle=90, height=height, heights=heights,
				center=center, centerXYZ=centerXYZ);
}

/*
Wedge
	Is same as Right Angled Triangle with 2 different heights, and rotated.
	Good for creating support structures.
*/
module Wedge(a, b, w1, w2)
{
	rotate([90,0,0])
		Right_Angled_Triangle(a, b, heights=[w1, w2, w1], centerXYZ=[false, false, true]);
}

/*
Equilateral Triangle
	Create a Equilateral Triangle.

	l: Length of all sides (a, b & c)
	H: Triangle size will be based on the this 2D height
		When using H, l is ignored.
*/
module Equilateral_Triangle(
			l=10, H=undef, height=1, heights=undef,
			center=undef, centerXYZ=[true,false,false])
{
	L = (H==undef)?l:H/sin(60);
	Triangle(a=L,b=L,angle=60,height=height, heights=heights,
				center=center, centerXYZ=centerXYZ);
}

/*
Trapezoid
	Create a Basic Trapezoid (Based on Isosceles_Triangle)

            d
          /----\
         /  |   \
     a  /   H    \ c
       /    |     \
 angle ------------ angle
            b

	b: Length of side b
	angle: Angle at points angleAB & angleBC
	H: The 2D height at which the triangle should be cut to create the trapezoid
	heights: If vector of size 3 (Standard for triangles) both cd & da will be the same height, if vector have 4 values [ab,bc,cd,da] than each point can have different heights.
*/
module Trapezoid(
			b, angle=60, H, height=1, heights=undef,
			center=undef, centerXYZ=[true,false,false])
{
	validAngle = (angle < 90);
	adX = H / tan(angle);

	// Calculate Heights at each point
	heightAB = ((heights==undef) ? height : heights[0])/2;
	heightBC = ((heights==undef) ? height : heights[1])/2;
	heightCD = ((heights==undef) ? height : heights[2])/2;
	heightDA = ((heights==undef) ? height : ((len(heights) > 3)?heights[3]:heights[2]))/2;

	// Centers
	centerX = (center || (center==undef && centerXYZ[0]))?0:b/2;
	centerY = (center || (center==undef && centerXYZ[1]))?0:H/2;
	centerZ = (center || (center==undef && centerXYZ[2]))?0:max(heightAB,heightBC,heightCD,heightDA);

	// Points
	y = H/2;
	bx = b/2;
	dx = (b-(adX*2))/2;

	pointAB1 = [centerX-bx, centerY-y, centerZ-heightAB];
	pointAB2 = [centerX-bx, centerY-y, centerZ+heightAB];
	pointBC1 = [centerX+bx, centerY-y, centerZ-heightBC];
	pointBC2 = [centerX+bx, centerY-y, centerZ+heightBC];
	pointCD1 = [centerX+dx, centerY+y, centerZ-heightCD];
	pointCD2 = [centerX+dx, centerY+y, centerZ+heightCD];
	pointDA1 = [centerX-dx, centerY+y, centerZ-heightDA];
	pointDA2 = [centerX-dx, centerY+y, centerZ+heightDA];

	validH = (adX < b/2);

	if (validAngle && validH)
	{
		polyhedron(
			points=[	pointAB1, pointBC1, pointCD1, pointDA1,
						pointAB2, pointBC2, pointCD2, pointDA2 ],
			triangles=[	
				[0, 1, 2],
				[0, 2, 3],
				[4, 6, 5],
				[4, 7, 6],
				[0, 4, 1],
				[1, 4, 5],
				[1, 5, 2],
				[2, 5, 6],
				[2, 6, 3],
				[3, 6, 7],
				[3, 7, 0],
				[0, 7, 4]	] );
	} else {
		if (!validAngle) echo("Trapezoid invalid, angle must be less than 90");
		else echo("Trapezoid invalid, H is larger than triangle");
	}
}

//
//// Examples
//Triangle(a=5, b=15, angle=33, centerXYZ=[true,false,false]);
//translate([20,0,0]) Right_Angled_Triangle(a=5, b=20, centerXYZ=[false,true,false]);
//translate([45,0,0]) Wedge(a=5, b=20, w1=10, w2=5);
//translate([-20,0,0]) Trapezoid(b=20, angle=33, H=4, height=5, centerXYZ=[true,false,true]);
//
//translate([0,10,0]) Isosceles_Triangle(b=20, angle=33);
//translate([30,10,0]) Isosceles_Triangle(b=20, H=5);
//translate([-30,10,0]) Isosceles_Triangle(angle=33, H=5, center=true);
//
//translate([15,-25,0]) Equilateral_Triangle(l=20);
////translate([-15,-25,0]) Equilateral_Triangle(H=20);
//
//
//module triangle(tan_angle, a_len, depth)
//{
//    linear_extrude(height=depth) {
//        polygon(points=[[0,0],[a_len,0],[0,tan(tan_angle) * a_len]], paths=[[0,1,2]]);
//    }
//}

module arc( height, depth, radius, degrees ) {
    // http://www.thefrankes.com/wp/?p=2660
    // This dies a horible death if it's not rendered here 
    // -- sucks up all memory and spins out of control 
    render() {
        difference() {
            // Outer ring
            rotate_extrude($fn = 100)
                translate([radius - height, 0, 0])
                    square([height,depth]);
         
            // Cut half off
            translate([0,-(radius+1),-.5]) 
                cube ([radius+1,(radius+1)*2,depth+1]);
         
            // Cover the other half as necessary
            rotate([0,0,180-degrees])
            translate([0,-(radius+1),-.5]) 
                cube ([radius+1,(radius+1)*2,depth+1]);
         
        }
    }
}


module lampholder_kwart() {
    linear_extrude(height = 4.5, center = true, convexity = 10, twist = 0, slices = 20, scale = 1.0)
        polygon([
            [0,9],
            [7,7],
            [8,6],
            [9,0]
        ]);
}
module lampholder_binnenkant() {
    translate([0,0,-2.2])
        rotate(45)
            linear_extrude(4.5)
                square(size = [12.7, 12.7], center = true);
}

module lampholder_outside() {
    lampholder_kwart();
    mirror()
        lampholder_kwart();
    rotate(90)
        mirror()
            lampholder_kwart();
    rotate(180)
        mirror()
            lampholder_kwart();
}

module lampholder() {
    lampholder_outside();
    lampholder_binnenkant();
    translate([0,0,1.2]) {
        lampholder_achterkant();
    }
}

module lampholders() {
    //right
    lampholder();
    //left
    translate([0,35,0])
        lampholder();
    //top
    translate([20,15,0])
        lampholder();
}

module lampholder_kap()  {
    arc(5,120,110,180);
}



module lampholder_kap_met_afsnede() {
    intersection() {
        rotate([0,90,0])
            translate([-1.6,0,-8])
                cylinder(h=10,r=10);
        translate([1,0,2])
            scale([0.08,0.08,0.08])
                lampholder_kap();
    }
}

module lampholder_achterkant() {
translate([0,0,-4])
    cylinder(h=2,r=10);
}

module lamp_bol(color) {
    translate([1,0,-4]) {
        difference() {
            color(color)
            sphere(r=9.9);
            translate([-10,-10,-10]) {
                color(color) 
                cube([20,20,16]);
            }
        }
    }

}

module lampholder_compleet(color) {
    lampholder();
    lampholder_kap_met_afsnede();
    lamp_bol(color);
}

module achterkant() {
    translate([0,-12,0]) {
        rotate(90) {
            minkowski(){
                render()
                driehoek();
                lampholder_achterkant();
            }
        }
    }
}

module driehoek() {
    translate([-13,0.5,0]) {
        Triangle(a=20, b=26, angle=50);
    }
}

module body() {
    achterkant();
    translate([0,0,-3])
        achterkant();
    translate([0,0,-6])
        achterkant();
    translate([0,0,-9])
        achterkant();
    translate([0,0,-12])
        achterkant();
}

module voorkant_met_lampholders() {
    translate([-0.8,0.9,0])
        lampholder_compleet("Green");
    translate([-15.7,-12.2,0])
        lampholder_compleet("Maroon");
    translate([-0.8,-24.9,0])
        lampholder_compleet("Orange");
}

module afdek_zijkant() {
    difference() {
        translate([0,0,-0.45]) {
            cube([7.5,20,1]);
        }
        translate([1.5,2,-0.55]) {
            cylinder(r=1, h=0.2, $fn=50);
        }
        translate([1.5,18,-0.55]) {
           cylinder(r=1, h=0.2, $fn=50);
        }
        translate([6,2,-0.55]) {
            cylinder(r=1, h=0.2, $fn=50);
        }
        translate([6,18,-0.55]) {
           cylinder(r=1, h=0.2, $fn=50);
        }
    }
}

module twee_afdekkappen() {
    translate([-22,-4.2,-3]) {
        rotate([49,90,0]) {
            afdek_zijkant();
        }
    }

    translate([-6,-33.5,-3]) {
        rotate([-50,90,0]) {
            afdek_zijkant();
        }
    }
}

module achterkant_stok(length) {
    translate([-7,-11.5,-16]) {
        rotate([90,45,270]) {
            cylinder(length,1.3,0.3,$fn=4);
                translate([0,0,11]) {
                   rotate([0,88,-45]) {
                    cylinder(r=1, h=0.5, $fn=50);
                }
            }
        }
    }
}

module achterkant_gat() {
    translate([-4.2,-11.5,-16]) {
        rotate([0,180,90]) {
            difference() {
                cylinder(r=3, $fn=50);
                cylinder(r=1.5, $fn=50);
            }
        }
    }
}

module achterkant_body() {
    achterkant_gat();
    //boven
    achterkant_stok(18);
    //rechts
    translate([-16,-9.5,0]) {
        rotate(102) {
                achterkant_stok(20);
        }
    }
    //links
    translate([6,-19,0]) {
        rotate(258) {
                achterkant_stok(20);
        }
    }
    translate([0,-13,-20]) {
        slotgat_achterkant();
    }
}

module slotgat_achterkant() {
    difference() {
            translate([0,0,1]) {
                cube([0.5,3,4]);
            }
            translate([-0.5,1.5,1.5]) {
                rotate([0,90,0]) {
                    cylinder(r=0.8, h=1.5, $fn=50);
                }
            }
        }
        
    intersection() {
        difference() {
            translate([-0.5,1.5,1.5]) {
                rotate([0,90,0]) {
                    cylinder(r=1.7, h=1.5, $fn=50);
                }
            }
                translate([-1.5,-1,1]) {
                cube([3,5,3]);
            }
        }
        difference() {
            cube([0.5,3,5]);
            translate([-0.5,1.5,1.5]) {
                rotate([0,90,0]) {
                    cylinder(r=0.8, h=1.5, $fn=50);
                }
            }
        }
    }
}


voorkant_met_lampholders();
body();
twee_afdekkappen();
achterkant_body();
