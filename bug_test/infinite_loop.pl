#
# Related to RT ticket 4939
#
use GD;
use GD::Graph;
use GD::Graph::lines;

@data = (
   ["1st"],
   [    -1],
 );

$graph = GD::Graph::lines->new(400, 300);
$graph->set(
     x_label           => 'X Label',
     y_label           => 'Y label',
     title             => 'Some simple graph',
     y_max_value       => 8,
     y_tick_number     => 8,
     y_label_skip      => 2,
     transparent       => 0,
);

$gd = $graph->plot(\@data);
open(OUT, ">$0.png") or die;
binmode(OUT);
print OUT $gd->png;

