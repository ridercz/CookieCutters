/* OSBS:build */

/* [Shape] */
image_file = "SVG/Wolfdog.svg";
mirror_options = [1, 0, 0];

/* [Construction] */
total_height = 15;
wall_thickness = .86;
base_width = 3;
base_height = 1.2;

/* [Grid] */
use_grid = false;
grid_size  = [200, 200];
grid_width = 3;
grid_span = 15;
grid_rotation = 45;


// Main shape
mirror(mirror_options) {
    // Cutting edge
    linear_extrude(total_height) difference() {
        offset(delta = wall_thickness) import(image_file, center = true);
        import(image_file, center = true);
    }

    // Base
    linear_extrude(base_height) difference() {
        offset(r = wall_thickness + base_width) import(image_file, center = true);
        offset(r = -base_width) import(image_file, center = true);
    }

    // Grid
    if(use_grid) {
        linear_extrude(base_height) intersection() {
            import(image_file, center = true);
            rotate(grid_rotation) translate(grid_size / -2) {
                for(offset = [0 : grid_span : grid_size[0]]) translate([0, offset - grid_width / 2]) square([grid_size[1], grid_width]);
                for(offset = [0 : grid_span : grid_size[1]]) translate([offset - grid_width / 2, 0]) square([grid_width, grid_size[0]]);
            }
        }
    }
}