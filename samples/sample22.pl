use GD::Graph::area;
require 'save.pl';

print STDERR "Processing sample 2-2\n";

@data = ( 
    ["1st","2nd","3rd","4th","5th","6th","7th", "8th", "9th"],
    [    5,   12,   24,   33,   19,    8,    6,    15,    21],
    [   -1,   -2,   -5,   -6,   -3,  1.5,    1,   1.3,     2]
);

$my_graph = new GD::Graph::area();

$my_graph->set( 
	two_axes => 1,
	zero_axis => 1,
);

$my_graph->set_legend( 'left axis', 'right axis' );
$my_graph->plot(\@data);
save_chart($my_graph, 'sample22');

