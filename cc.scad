/****************************************************************************
 * Altair's 2D Objects for OpenSCAD              version 4.0.1 (2021-12-08) *
 * Copyright (c) Michal A. Valasek, 1998-2021                               *
 * Licensed under terms of the MIT license                                  *
 * ------------------------------------------------------------------------ *
 * www.rider.cz * www.altair.blog * github.com/ridercz/CookieCutters        *
 ****************************************************************************/

/* [Shape] */
// Path to SVG file
image_file = "SVG/Wolfdog.svg";
// Normal vector to mirror in [x, y, z]
mirror_options = [1, 0, 0];

/* [Construction] */
// Cutter height including base
total_height = 15;
// Cutter wall thickness
wall_thickness = .86;
// Base width, excluding cutter wall thickness
base_width = 6;
// Base height
base_height = 1.2;

/* [Grid] */
// Enable grid use (for compound shapes)
use_grid = false;
// Total grid size (should be bigger than the shape)
grid_size  = [200, 200];
// Grid lines width
grid_width = 3;
// Grid lines span
grid_span = 15;
// Grid rotation in degrees
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
        offset(r = wall_thickness + base_width / 2) import(image_file, center = true);
        offset(r = -base_width / 2) import(image_file, center = true);
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