use GD::Graph::bars;
use GD::Graph::colour;
require 'save.pl';

print STDERR "Processing sample 1-1\n";

@data = ( 
    ["1st","2nd","3rd","4th","5th","6th","7th", "8th", "9th"],
    [    1,    2,    5,    6,    3,  1.5,    1,     3,     4],
);

$my_graph->set( 
	x_label => 'X Label',
	y_label => 'Y label',
	title => 'A Simple Bar Chart',
	y_max_value => 8,
	y_tick_number => 8,
	y_label_skip => 2,
	
	# shadows
	bar_spacing => 8,
	shadow_depth => 4,
	shadowclr => 'dred',
) 
or warn $my_graph->error;

$my_graph->plot(\@data) or die $my_graph->error;
save_chart($my_graph, 'sample11');

