#! /usr/bin/perl

# This program demonstrates a problem with horizontal lines appearing
# with an area chart
#
# Cannot reproduce this problem on my box. See other scripts for bare GD
# test: poly.pl

use lib 'blib/lib';
use GD;
use GD::Graph::area;

my @data = ( [ qw/ 1 2 3 4 5 6 / ],
  [ qw/3  8 5 5 2 8/ ] );


my $graph = new GD::Graph::area (480,480);

my $g = $graph->plot(\@data);
open(FOO, ">graf1.png") or die $!;
binmode FOO;
print FOO $g->png;
close FOO;
