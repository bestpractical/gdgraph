#!/usr/bin/perl

use strict;
use warnings;

use GD::Graph::pie;

my $graph = GD::Graph::pie->new(200, 200);

my $img = $graph->plot([['slice 1', 'slice 2'], [28, 100]]);

print $img->png();

