#==========================================================================
#			   Copyright (c) 1995-1998 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GD::Graph::bars.pm
#
# $Id: bars.pm,v 1.2 1999/12/11 12:50:48 mgjv Exp $
#
#==========================================================================
 
package GD::Graph::bars;

use strict;

use GD::Graph::axestype;
use GD::Graph::utils qw(:all);

@GD::Graph::bars::ISA = qw( GD::Graph::axestype );

my %Defaults = (
	
	# Spacing between the bars
	bar_spacing 	=> 0,
);

sub initialise
{
	my $self = shift;

	$self->SUPER::initialise();

	my $key;
	foreach $key (keys %Defaults)
	{
		$self->set( $key => $Defaults{$key} );
	}
}

# PRIVATE
sub draw_data
{
	my $s = shift;
	my $d = shift;
	my $g = $s->{graph};

	if ( $s->{overwrite} ) 
	{
		$s->draw_data_overwrite($d);
	} 
	else 
	{
		$s->SUPER::draw_data($d);
	}

	# redraw the 'zero' axis
	$g->line( 
		$s->{left}, $s->{zeropoint}, 
		$s->{right}, $s->{zeropoint}, 
		$s->{fgci} );
}

# Draws the bars on top of each other

sub draw_data_overwrite 
{
	my $s = shift;
	my $d = shift;
	my $g = $s->{graph};
	my $bar_s = _round($s->{bar_spacing}/2);

	my $zero = $s->{zeropoint};

	my $i;
	for $i (0 .. $s->{numpoints}) 
	{
		my $bottom = $zero;
		my ($xp, $t);

		my $j;
		for $j (1 .. $s->{numsets}) 
		{
			next unless (defined $d->[$j][$i]);

			# get data colour
			my $dsci = $s->set_clr($s->pick_data_clr($j));

			# get coordinates of top and center of bar
			($xp, $t) = $s->val_to_pixel($i + 1, $d->[$j][$i], $j);

			# calculate left and right of bar
			my $l = $xp - _round($s->{x_step}/2) + $bar_s;
			my $r = $xp + _round($s->{x_step}/2) - $bar_s;

			# calculate new top
			$t -= ($zero - $bottom) if ($s->{overwrite} == 2);

			# draw the bar
			if ($d->[$j][$i] >= 0)
			{
				# positive value
				$g->filledRectangle( $l, $t, $r, $bottom, $dsci );
				$g->rectangle( $l, $t, $r, $bottom, $s->{acci} );
			}
			else
			{
				# negative value
				$g->filledRectangle( $l, $bottom, $r, $t, $dsci );
				$g->rectangle( $l, $bottom, $r, $t, $s->{acci} );
			}

			# reset $bottom to the top
			$bottom = $t if ($s->{overwrite} == 2);
		}
	}
 }

sub draw_data_set
{
	my $s = shift;
	my $d = shift;
	my $ds = shift;
	my $g = $s->{graph};
	my $bar_s = _round($s->{bar_spacing}/2);

	# Pick a data colour
	my $dsci = $s->set_clr($s->pick_data_clr($ds));

	my $i;
	for $i (0 .. $s->{numpoints}) 
	{
		next unless (defined $d->[$i]);

		# get coordinates of top and center of bar
		my ($xp, $t) = $s->val_to_pixel($i + 1, $d->[$i], $ds);

		# calculate left and right of bar
		my ($l, $r);

		if ($s->{mixed})
		{
			$l = $xp - _round($s->{x_step}/2) + $bar_s;
			$r = $xp + _round($s->{x_step}/2) - $bar_s;
		}
		else
		{
			$l = $xp 
				- _round($s->{x_step}/2)
				+ _round(($ds - 1) * $s->{x_step}/$s->{numsets})
				+ $bar_s;
			$r = $xp 
				- _round($s->{x_step}/2)
				+ _round($ds * $s->{x_step}/$s->{numsets})
				- $bar_s;
		}

		# draw the bar
		if ($d->[$i] >= 0)
		{
			# positive value
			$g->filledRectangle( $l, $t, $r, $s->{zeropoint}, $dsci );
			$g->rectangle( $l, $t, $r, $s->{zeropoint}, $s->{acci} );
		}
		else
		{
			# negative value
			$g->filledRectangle( $l, $s->{zeropoint}, $r, $t, $dsci );
			$g->rectangle( $l, $s->{zeropoint}, $r, $t, $s->{acci} );
		}
	}
}

1;
