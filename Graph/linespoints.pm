#==========================================================================
#			   Copyright (c) 1995-1998 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GD::Graph::linespoints.pm
#
# $Id: linespoints.pm,v 1.2 1999/12/11 12:50:48 mgjv Exp $
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

@GD::Graph::linespoints::ISA = qw( GD::Graph::lines GD::Graph::points );

sub initialise
{
	my $s = shift;

	$s->GD::Graph::lines::initialise();
	$s->GD::Graph::points::initialise();
}

# PRIVATE

sub draw_data_set # GD::Image, \@data, $ds
{
	my $s = shift;
	my $g = shift;
	my $d = shift;
	my $ds = shift;

	#print "points->\n";
	$s->GD::Graph::points::draw_data_set( $g, $d, $ds );
	#print "lines->\n";
	$s->GD::Graph::lines::draw_data_set( $g, $d, $ds );
	#print "done->\n";
}

sub draw_legend_marker # (GD::Image, data_set_number, x, y)
{
	my $s = shift;
	my $g = shift;
	my $n = shift;
	my $x = shift;
	my $y = shift;

	$s->GD::Graph::points::draw_legend_marker($g, $n, $x, $y);
	$s->GD::Graph::lines::draw_legend_marker($g, $n, $x, $y);
}

1;
