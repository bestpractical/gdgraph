#!/usr/bin/perl -w
use lib 'samples';
use lib 'blib/lib';
use GD::Graph::lines;
require 'save.pl';

print STDERR "Processing sample 5-7\n";

# The reverse is in here, because I thought the falling line was 
# depressing, but I was too lazy to retype the data set

@data = ( 
    [ qw( Jan Feb Mar Apr May Jun Jul Aug Sep ) ],
    [ 4, 3, 5, 8, 3,  3.5, 4, 2.0, 4.5],
);

$my_graph = new GD::Graph::lines();

$my_graph->set( 
	x_label => 'Month',
	y_label => 'Measure of success',
	title => 'A Simple Line Graph',
	box_axis => 0,
	y_max_value => 9,
	y_min_value => 1,
	line_width => 3,
	zero_axis_only => 1,
	transparent => 0,
);

$my_graph->set_legend('Test');

$my_graph->plot(\@data);
save_chart($my_graph, 'sample57');

