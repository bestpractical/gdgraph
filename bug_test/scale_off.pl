#!/usr/bin/perl -w 
# Test of report
# From: Michael Ho <mho@hk.dhl.com>
# Date: Wed, 21 Jun 2000 17:18:34 +0800
# Subject: Problem on using GD::Graph
#
# Cannot reproduce problem

use strict;
use GD::Graph::bars;
use GD::Graph::Data;

my $data = GD::Graph::Data->new([
[qw(01 02 03 04 05 06 07 08 09 10 11 12)],
[qw(1   2   3   4   5   6  7   8   9  10  11 12)],
[qw(12 11 10  9  8   0   0   0   0  0   0   0)]
]) or die GD::Graph::Data->error;

my $my_graph = GD::Graph::bars->new();

$my_graph->set( 
	transparent => 0,
) 
or warn $my_graph->error;

my $gd = $my_graph->plot($data) or die $my_graph->error;
open(FOO, ">scale_off.png") or die $!;
binmode FOO;
print FOO $gd->png;
close FOO;

