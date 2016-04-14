// oud model deursleutel
// license: GNU GPLv3


$fn = 100;
module long_hole_in_armkey() {
	hull() {
		translate([-6,0,0]) {
			rotate([0,90,0]) {
				cylinder(12,2,2);
			}
		}
		translate([-6,0,7]) {
			rotate([0,90,0]) {
				cylinder(12,2,2);
			}
		}
	}
}

module short_hole_in_armkey() {	
	translate([-6,0,5]) {
		rotate([0,90,0]) {
			cylinder(12,2,2);
		}
	}
}

module inverse_circle_corner() {
	difference() {
		translate([0,0,-2.5]) {
			cube([5,5,5]);
		}
		cylinder(5.5,5,5, center=true);
	}
}

module handle() {
	union() {
		translate([15,10,0]) {
			union() {
				cube([15,10,3]);
				translate([14,5,0]) {
					cylinder(3,5,5);
				}
			}
		}
		rotate([0,0,30]) {
			cube([23,10,3]);
		}
	}
}

module handle_with_hole() {
	difference() {
		handle();
		translate([29,15,-0.1]) {
			cylinder(3.2,3,3);
		}
	}
}

module armkey() {
	intersection() {
		cylinder(60,6,6);
		resize([9,3.5,0]) {
			translate([0,-10,50.5]) {
				rotate([0,90,0]) {
					inverse_circle_corner();
				}
			}
		}
	}
	difference() {
		cylinder(60,6,6);
		
		translate([0,-5,53]) {
			cube([10,2,15], true );
		}
		translate([0,0,11]) {
			long_hole_in_armkey();
		}
		translate([0,0,34]) {
			long_hole_in_armkey();
		}
		translate([-0,0,45]) {
			linear_extrude(height = 41, center = true, convexity = 10)
			polygon(points=[	[-4,-2],
						   	[4,-2],
							[0,5]],
			    		paths=[[0,1,2]]);
 			} 
	}

	translate([0,-6,60-1.5]) {
		cube([3,6,3], true );
	}
}

module resistor() { 
	color("LimeGreen") {
		linear_extrude(height=4) {
			polygon(points = [
				[-9.00,-2.00]
				,[-5.00,-2.00]
				,[-4.00,0.00]
				,[-2.00,-4.00]
				,[0.00,0.00]
				,[2.00,-4.00]
				,[4.00,0.00]
				,[6.00,-4.00]
				,[7.00,-2.00]
				,[11.00,-2.00]
				,[11.00,-1.00]
				,[7.00,-1.00]
				,[6.00,-2.00]
				,[4.00,2.00]
				,[2.00,-2.00]
				,[0.00,2.00]
				,[-2.00,-2.00]
				,[-4.00,2.00]
				,[-6.00,-1.00]
				,[-9.00,-1.00]
			]
			,paths = [
				[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19]]
	          	  );
		}
	}
}

module fullkey() {
	armkey();
	difference() {
		union() {	
			translate([1.5,-2,15]) {
				rotate([270,0,90]) {
					handle_with_hole();
				}
			}
			translate([-1.5,2,15]) {
				rotate([270,0,270]) {
					handle();
					translate([20,16,1]) {	
						resistor();
					}
				}
			}	
		}
		translate([0,0,11]) {
			long_hole_in_armkey();
		}
	}
}

fullkey();