#==========================================================================
#			   Copyright (c) 1995-1998 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GD::Graph::bars.pm
#
# $Id: bars.pm,v 1.9 2000/02/13 03:55:43 mgjv Exp $
#
#==========================================================================
 
package GD::Graph::bars;

use strict;

use GD::Graph::axestype;
use GD::Graph::utils qw(:all);
use GD::Graph::colour qw(:colours);

@GD::Graph::bars::ISA = qw(GD::Graph::axestype);

sub draw_data
{
	my $s = shift;
	my $d = shift;

	if ( $s->{overwrite} ) 
	{
		$s->draw_data_overwrite($d);
	} 
	else 
	{
		$s->SUPER::draw_data($d);
	}

	# redraw the 'zero' axis
	$s->{graph}->line( 
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

	# CONTRIB Jeremy Wadsack, shadows
	my $bsd = $s->{shadow_depth} and
		my $bsci = $s->set_clr(_rgb($s->{shadowclr}));
		
	for my $i (0 .. $s->{_data}->num_points - 1) 
	{
		my $bottom = $zero;
		my ($xp, $t);

		my $total = 0;
		for my $j (1 .. $s->{_data}->num_sets)
		{
			next unless defined $d->[$j][$i];

			# ALERT from Edwin Hildebrand, including patch. His patch
			# inapplicable, because of change in behaviour of colors
			# (as in sample17) This fixed problems with sample18.
			#
			# Instead of using rounded values to offset bars for
			# overwrite == 2, well keep track a bit more exactly.
			(undef, $bottom) = $s->val_to_pixel($i + 1, $total, $j)
				if $s->{overwrite} == 2;
			$total += $d->[$j][$i];

			# get data colour
			# CONTRIB Jeremy Wadsack
			#
			# cycle_clrs option sets the color based on the point, 
			# not the dataset.
			my $dsci = $s->set_clr($s->pick_data_clr(
				$s->{cycle_clrs} ? $i + 1 : $j));
			# contrib "Bremford, Mike" <mike.bremford@gs.com>
			my $brci = $s->set_clr($s->pick_border_clr(
				$s->{cycle_clrs} > 1 ? $i + 1 : $j));

			# get coordinates of top and center of bar
			($xp, $t) = $s->{overwrite} == 2 ?
				$s->val_to_pixel($i + 1, $total, $j) :
				$s->val_to_pixel($i + 1, $d->[$j][$i], $j);
			
			# calculate left and right of bar
			my $l = $xp - _round($s->{x_step}/2) + $bar_s;
			my $r = $xp + _round($s->{x_step}/2) - $bar_s;

			if ($t <= $bottom)
			{
				# positive value
				$g->filledRectangle($l+$bsd, $t+$bsd, $r+$bsd, $bottom, $bsci)
					if $bsd;
				$g->filledRectangle($l, $t, $r, $bottom, $dsci);
				$g->rectangle($l, $t, $r, $bottom, $brci) 
					if ($r - $l > $s->{accent_treshold});
			}
			else
			{
				# negative value
				$g->filledRectangle($l+$bsd, $bottom, $r+$bsd, $t+$bsd, $bsci)
					if $bsd;
				$g->filledRectangle($l, $bottom, $r, $t, $dsci);
				$g->rectangle($l, $bottom, $r, $t, $brci)
					if ($r - $l > $s->{accent_treshold});
			}
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
	# contrib "Bremford, Mike" <mike.bremford@gs.com>
	my $brci = $s->set_clr($s->pick_border_clr($ds));

	# CONTRIB Jeremy Wadsack, shadows
	my $bsd = $s->{shadow_depth} and
		my $bsci = $s->set_clr(_rgb($s->{shadowclr}));

	for my $i (0 .. $s->{_data}->num_points - 1) 
	{
		next unless (defined $d->[$i]);

		# CONTRIB Jeremy Wadsack
		#
		# cycle_clrs option sets the color based on the point, 
		# not the dataset.
		$dsci = $s->set_clr($s->pick_data_clr($i + 1))
			if $s->{cycle_clrs};
		$brci = $s->set_clr($s->pick_data_clr($i + 1))
			if $s->{cycle_clrs} > 1;

		# get coordinates of top and center of bar
		my ($xp, $t) = $s->val_to_pixel($i + 1, $d->[$i], $ds);

		# calculate left and right of bar
		my ($l, $r);

		if (ref $s eq 'GD::Graph::mixed')
		{
			$l = $xp - _round($s->{x_step}/2) + $bar_s;
			$r = $xp + _round($s->{x_step}/2) - $bar_s;
		}
		else
		{
			$l = $xp 
				- _round($s->{x_step}/2)
				+ _round(($ds - 1) * $s->{x_step}/$s->{_data}->num_sets)
				+ $bar_s;
			$r = $xp 
				- _round($s->{x_step}/2)
				+ _round($ds * $s->{x_step}/$s->{_data}->num_sets)
				- $bar_s;
		}

		# draw the bar
		if ($d->[$i] >= 0)
		{
			# positive value
			$g->filledRectangle($l+$bsd, $t+$bsd, $r+$bsd, $s->{zeropoint}, 
				$bsci) if $bsd;
			$g->filledRectangle($l, $t, $r, $s->{zeropoint}, $dsci );
			$g->rectangle($l, $t, $r, $s->{zeropoint}, $brci)
				if ($r - $l > $s->{accent_treshold});
		}
		else
		{
			# negative value
			$g->filledRectangle($l+$bsd, $s->{zeropoint}, $r+$bsd, $t+$bsd, 
				$bsci) if $bsd;
			$g->filledRectangle($l, $s->{zeropoint}, $r, $t, $dsci);
			$g->rectangle($l, $s->{zeropoint}, $r, $t, $brci)
				if ($r - $l > $s->{accent_treshold});
		}
	}
}

1;
