#!/usr/bin/perl -w
use strict;

# This script identified a bug in 1.30, where a mixed type would always
# correct_width, even if it wasn't necessary

use lib '../blib/lib';

my $num = $ARGV[0] || 100;
print "Doing $num points\n";

use GD::Graph::lines;
use GD::Graph::mixed;
use GD::Graph::area;
use GD::Graph::bars;
use GD::Graph::Data;

$GD::Graph::Error::Debug = 10;

my $data = GD::Graph::Data->new();

for my $i ( 1..$num )
{
	$data->add_point($i, rand, rand 0.5, rand 0.25);
}

my $g = GD::Graph::mixed->new(300,200)
	or die "Hmm: ", GD::Graph->error();

$g->set(
	      x_label => 'Iteration',
	      y_label => 'Jobs Processed',
	      title => "Number of Jobs",
	      long_ticks => 1,
		  x_label_skip => 25,
	      line_width => 2,
	      y_tick_number => 50,
		  #correct_width => 0,
		  types => [qw(lines bars lines)],
	      overwrite => 1,
) 
	or warn $g->error;

$g->plot($data) 
	or die "Cannot plot: ", $g->error();

open(FOO, ">/tmp/foo.png") or die $!;
binmode FOO;
print FOO $g->gd->png;
close FOO;
