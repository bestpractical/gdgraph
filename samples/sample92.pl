use GD::Graph::pie;

print STDERR "Processing sample 9-2\n";

@data = ( 
    ["1st","2nd","3rd","4th","5th","6th"],
    [    4,    2,    3,    4,    3,  3.5]
);

$my_graph = new GD::Graph::pie( 250, 200 );

$my_graph->set( 
	title 			=> 'A Pie Chart',
	label 			=> 'Label',
	axislabelclr 	=> 'white',
	dclrs 			=> [ 'lblue' ],
	accentclr 		=> 'lgray',
);

$my_graph->set_title_font('../20thcent.ttf', 18);
$my_graph->set_label_font('../20thcent.ttf', 12);
$my_graph->set_value_font('../cetus.ttf', 10);

$my_graph->plot_to_png( "sample92.png", \@data );

