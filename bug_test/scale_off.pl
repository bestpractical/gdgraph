#!/usr/bin/perl -w 
# Test of report
# From: Michael Ho <mho@hk.dhl.com>
# Date: Wed, 21 Jun 2000 17:18:34 +0800
# Subject: Problem on using GD::Graph

use GD::Graph::bars;

@data = (
['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'],
[75000, 60000, 84000, 80000, 98000, 85000, 85000, 82000, 81000, 83000, 103000,
100000],
[85000, 65000, 96000, 87000, 100000, 87000, 0,     0,     0,     0,     0,
0,]

);

$my_graph = new GD::Graph::bars();

$my_graph->set(
   t_margin => 10,
   b_margin => 10,
   l_margin => 10,
   r_margin => 10,
   x_label => 'Month',
   y_tick_number => 20,
   y_label_skip => 2,
   y_max_value => 120000,
   long_ticks => 1,
   legend_placement => 'RT',
   x_label_position => 1/2,
   fgclr => 'white',
   boxclr => 'dblue',
   accentclr => 'dblue',
   dclrs => [qw(lorange lgreen)],

   bar_spacing => 2,
   transparent => 0,

   title=>'Revenue between 1999 and 2000' ,
   y_label=>'Revenue HK$k',

);

$my_graph->set_legend( qw(offset increment more));
$gd = $my_graph->plot(\@data);
open(FOO, ">scale_off.png") or die $!;
binmode FOO;
print FOO $gd->png;
close FOO;

__END__

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

