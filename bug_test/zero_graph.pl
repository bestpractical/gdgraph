#!/usr/bin/perl -w

# Illustrates undefined values in _best_ends method when graph only
# contains 0, fixed for 1.31

use strict;
use lib 'blib/lib';
use GD::Graph::lines;

my @data = (
        [ "1st", "2nd", "3rd", "4th" ],
        [ 0, 0, 0, 0 ],
        [ 0, 0, 0, 0 ],
);

my $graph = GD::Graph::lines->new(300, 400);

$graph->set(transparent => 0);	
$graph->plot(\@data) or die $graph->error;

open(IMG, '>zero_graph.png') or die $!;
binmode IMG;
print IMG $graph->gd->png;
close IMG;

