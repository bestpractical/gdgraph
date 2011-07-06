use strict;
use GD::Graph::bars;
use GD::Graph::hbars;

my @data = ( 
    ["1st","2nd","3rd","4th","5th","6th","7th", "8th", "9th"],
    [    5,   12,   24,   33,   19,    8,    6,    15,    21],
    [    1,    2,    5,    6,    3,  1.5,    1,     3,     4],
);

my %options = (
    x_label         => 'X Label',
    y_label         => 'Y label',
    title           => 'Two data sets',
    long_ticks      => 1,
    y_max_value     => 40,
    y_tick_number   => 8,
    y_label_skip    => 2,
    bar_spacing     => 3,
    shadow_depth    => 4,

    accent_treshold => 200,

    transparent     => 0,
);

# Create a chart with a legend at the bottom
my $my_graph = GD::Graph::hbars->new(600, 400);
$my_graph->set( %options );
$my_graph->set_legend('Data set 1', 'Data set 2');

# Investigate how the legend changes the margins
my ($l, $r, $t, $b) = get_margin($my_graph);
print "BEFORE: $l, $r, $t, $b\n";
$my_graph->plot(\@data);
($l, $r, $t, $b) = get_margin($my_graph);
print "AFTER:  $l, $r, $t, $b\n";

save_chart($my_graph, 'with_legend');

# We can now see that the bottom margin is 20 pixels larger than before, 
# so we need to make our new picture 20 pixels lower, or we need to give
# it an empty margin at the bottom

my $smaller_graph = GD::Graph::hbars->new(600, 400 - $b);
$smaller_graph->set( %options );
$smaller_graph->plot(\@data);
save_chart($smaller_graph, 'smaller');

my $margin_graph = GD::Graph::hbars->new(600, 400);
$margin_graph->set( %options, 
    b_margin => $b 
);
$margin_graph->plot(\@data);
save_chart($margin_graph, 'margin');



sub get_margin {
    my $g = shift;
    return (
        $my_graph->{l_margin}, 
        $my_graph->{r_margin}, 
        $my_graph->{t_margin}, 
        $my_graph->{b_margin}, 
    );
}

sub save_chart
{
	my $chart = shift or die "Need a chart!";
	my $name = shift or die "Need a name!";
        my $ext = 'png';

	open my $out, ">$name.$ext" or 
		die "Cannot open $name.$ext for write: $!";
        binmode $out;
	print $out $chart->gd->$ext();
}
