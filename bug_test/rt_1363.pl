use strict;

use GD::Graph::mixed;

## define your data set
my @data = ( 
               ["1st","2nd","3rd","4th","5th","6th","7th", "8th", "9th"],
               [    1,    2,    5,    6,    7,  8,   9,    10,    11],
               [   2,   2,    1,    1,   3, 2,   2,    4,     0],
               [    9,    8,    9, 5,  7,  7,    8,     3,    3]  );


my $my_graph = new GD::Graph::mixed();

$my_graph->set( 
               types => [ qw( lines) ],
               default_type => 'bars',
               );


$my_graph->set( 
                  
                  x_label         => 'X Label',
                  y_label         => 'Y label',
                  title           => 'A Mixed Type Graph',
                  
                  y1_max_value        => 40,
                  y2_max_value        => 8,
                  y_min_value     => 0,
                  y_tick_number   => 8,
                  y_label_skip    => 1,
                  x_plot_values   => 0,
                  y_plot_values   => 0,
                  
                  long_ticks      => 1,
                  x_ticks         => 0,
                  
                  legend_marker_width => 24,
                  line_width      => 3,
                  marker_size     => 5,
                  
                  bar_width       => 4,
                  #bar_spacing     => 1,
                  
                  transparent     => 0,
                  
                  
                  values_vertical     => 1,
                  values_format       => "%4.1f",
                  x_label_position    => 1/2,
                  cumulate            => 0,
                  overwrite           => 1      );
                  
   
   
   $my_graph->set_legend( qw( incomming outgoing total ) );
   $my_graph->plot(\@data) or die $my_graph->error;
   save_chart($my_graph, 'bars_all_over_each_other');


sub save_chart($$)
{
	my $chart = shift or die "Need a chart!";
	my $name = shift or die "Need a name!";
	local(*OUT);

	my $ext = $chart->export_format;

	open(OUT, "> $name.$ext") or 
		die "Cannot open $name.$ext for write: $!";
	binmode OUT;
	print OUT $chart->gd->$ext();
	close OUT;
}
