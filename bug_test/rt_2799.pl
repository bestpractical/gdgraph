#!/usr/bin/perl

use GD::Graph::bars;

my $graph=GD::Graph::bars->new(580,250);
$graph->set(
        bar_spacing => 8,
        x_labels_vertical => 1,
        x_label => 'Location',
        y_label => 'No of xxxx',
        title => 'Location',
        dclrs => ['blue']
);

my @data = (
        [ qw/A B C D E F G H I J K L M N O Other Unrecorded/ ],
        [1, 1, 1, 2, 1, 3, 6, 2, 1, 1, 1, 3, 5, 4, 1, 1, 5 ]
);

$graph->plot(\@data);
print($graph->gd->png());

=pod

This message about GDGraph was sent to you by guest <> via rt.cpan.org

Full context and any attached attachments can be found at:
<URL: https://rt.cpan.org/Ticket/Display.html?id=2799 >

As the following code demonstrates, the code for choosing the axes needs to be
tweaked to take into account the need for bar graphs to have their axes zeroed.
The attached patch seems to fix the problem in the case of graphs with only one
axis, but I'm sure there must be a cleaner way of doing this.

Without the patch, the following data ends up with range [1,6], five ticks =>
step size of 1, but then the min_y is subsequently set to zero, resulting in a
step size of 1.2 - not very aesthetically pleasing (the graph is counting whole
objects). With the patch, the range is [0,6], so _best_ends chooses a step size
of 2 and increases the range to [0,10] - which is exactly what we want in this
case.

Cheers,

Jamie Walker.

=cut
