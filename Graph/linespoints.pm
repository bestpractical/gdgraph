#==========================================================================
#			   Copyright (c) 1995-1998 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GD::Graph::linespoints.pm
#
# $Id: linespoints.pm,v 1.3 2000/01/07 13:44:42 mgjv Exp $
#
#==========================================================================

package GD::Graph::linespoints;
 
use strict;
 
use GD::Graph::axestype;
use GD::Graph::lines;
use GD::Graph::points;
 
# Even though multiple inheritance is not really a good idea,
# since lines and points have the same parent class, I will do it here,
# because I need the functionality of the markers and the line types

@GD::Graph::linespoints::ISA = qw(GD::Graph::lines GD::Graph::points);

# PRIVATE

sub draw_data_set # \@data, $ds
{
	my $s = shift;
	my $d = shift;
	my $ds = shift;

	$s->GD::Graph::points::draw_data_set($d, $ds);
	$s->GD::Graph::lines::draw_data_set($d, $ds);
}

sub draw_legend_marker # (data_set_number, x, y)
{
	my $s = shift;
	my $n = shift;
	my $x = shift;
	my $y = shift;

	$s->GD::Graph::points::draw_legend_marker($n, $x, $y);
	$s->GD::Graph::lines::draw_legend_marker($n, $x, $y);
}

1;
