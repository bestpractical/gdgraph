#==========================================================================
#			   Copyright (c) 1995-2000 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GD::Graph::area.pm
#
# $Id: area.pm,v 1.7 2000/02/13 03:55:43 mgjv Exp $
#
#==========================================================================

package GD::Graph::area;
 
use strict;

use GD::Graph::axestype;

@GD::Graph::area::ISA = qw( GD::Graph::axestype );

# PRIVATE
sub draw_data_set  # GD::Image, \@data, $ds
{
	my $s = shift;		# object reference
	my $d = shift;		# reference to data set
	my $ds = shift;		# number of the data set
	my $g = $s->{graph};

	my $num = 0;

	# Select a data colour
	my $dsci = $s->set_clr($s->pick_data_clr($ds));
	my $brci = $s->set_clr($s->pick_border_clr($ds));

	# Create a new polygon
	my $poly = new GD::Polygon();

	# Add the first 'zero' point
	my ($x, $y) = $s->val_to_pixel(1, 0, $ds);
	$poly->addPt($x, $y);

	# Add the data points
	my $i;
	for $i (0 .. $s->{_data}->num_points - 1) 
	{
		next unless (defined $d->[$i]);

		($x, $y) = $s->val_to_pixel($i + 1, $d->[$i], $ds);
		$poly->addPt($x, $y);

		$num = $i;
	}

	# Add the last zero point
	($x, $y) = $s->val_to_pixel($num + 1, 0, $ds);
	$poly->addPt($x, $y);

	# Draw a filled and a line polygon
	$g->filledPolygon($poly, $dsci);
	$g->polygon($poly, $brci);

	# Draw the accent lines
	if (($s->{right} - $s->{left})/($s->{_data}->num_points) > 
			$s->{accent_treshold})
	{
		for $i (1 .. ($s->{_data}->num_points - 2)) 
		{
			next unless (defined $d->[$i]);
			($x, $y) = $s->val_to_pixel($i + 1, $d->[$i], $ds);
			$g->dashedLine($x, $y, $x, $s->{zeropoint}, $brci);
		}
	}
}
 
1;
