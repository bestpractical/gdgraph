#==========================================================================
#			   Copyright (c) 1995-1998 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GD::Graph::bars.pm
#
# $Id: bars.pm,v 1.10 2000/02/13 06:13:24 mgjv Exp $
#
#==========================================================================
 
package GD::Graph::bars;

use strict;

use GD::Graph::axestype;
use GD::Graph::utils qw(:all);
use GD::Graph::colour qw(:colours);

@GD::Graph::bars::ISA = qw(GD::Graph::axestype);

sub draw_data_old
{
	my $self = shift;

	if ( $self->{overwrite} ) 
	{
		$self->draw_data_overwrite();
	} 
	else 
	{
		$self->SUPER::draw_data();
	}

	# redraw the 'zero' axis
	$self->{graph}->line( 
		$self->{left}, $self->{zeropoint}, 
		$self->{right}, $self->{zeropoint}, 
		$self->{fgci} );
}

# Draws the bars on top of each other

sub draw_data_overwrite 
{
	my $self = shift;
	my $d = $self->{_data};
	my $g = $self->{graph};
	my $bar_s = _round($self->{bar_spacing}/2);

	my $zero = $self->{zeropoint};

	# CONTRIB Jeremy Wadsack, shadows
	my $bsd = $self->{shadow_depth} and
		my $bsci = $self->set_clr(_rgb($self->{shadowclr}));
		
	for my $i (0 .. $self->{_data}->num_points - 1) 
	{
		my $bottom = $zero;
		my ($xp, $t);

		my $total = 0;
		for my $j (1 .. $self->{_data}->num_sets)
		{
			next unless defined $d->[$j][$i];

			# ALERT from Edwin Hildebrand, including patch. His patch
			# inapplicable, because of change in behaviour of colors
			# (as in sample17) This fixed problems with sample18.
			#
			# Instead of using rounded values to offset bars for
			# overwrite == 2, well keep track a bit more exactly.
			(undef, $bottom) = $self->val_to_pixel($i + 1, $total, $j)
				if $self->{overwrite} == 2;
			$total += $d->[$j][$i];

			# get data colour
			# CONTRIB Jeremy Wadsack
			#
			# cycle_clrs option sets the color based on the point, 
			# not the dataset.
			my $dsci = $self->set_clr($self->pick_data_clr(
				$self->{cycle_clrs} ? $i + 1 : $j));
			# contrib "Bremford, Mike" <mike.bremford@gs.com>
			my $brci = $self->set_clr($self->pick_border_clr(
				$self->{cycle_clrs} > 1 ? $i + 1 : $j));

			# get coordinates of top and center of bar
			($xp, $t) = $self->{overwrite} == 2 ?
				$self->val_to_pixel($i + 1, $total, $j) :
				$self->val_to_pixel($i + 1, $d->[$j][$i], $j);
			
			# calculate left and right of bar
			my $l = $xp - _round($self->{x_step}/2) + $bar_s;
			my $r = $xp + _round($self->{x_step}/2) - $bar_s;

			if ($t <= $bottom)
			{
				# positive value
				$g->filledRectangle($l+$bsd, $t+$bsd, $r+$bsd, $bottom, $bsci)
					if $bsd;
				$g->filledRectangle($l, $t, $r, $bottom, $dsci);
				$g->rectangle($l, $t, $r, $bottom, $brci) 
					if ($r - $l > $self->{accent_treshold});
			}
			else
			{
				# negative value
				$g->filledRectangle($l+$bsd, $bottom, $r+$bsd, $t+$bsd, $bsci)
					if $bsd;
				$g->filledRectangle($l, $bottom, $r, $t, $dsci);
				$g->rectangle($l, $bottom, $r, $t, $brci)
					if ($r - $l > $self->{accent_treshold});
			}
		}
	}
}

sub draw_data_set
{
	my $self = shift;
	my $ds = shift;

	my $bar_s = _round($self->{bar_spacing}/2);

	# Pick a data colour
	my $dsci = $self->set_clr($self->pick_data_clr($ds));
	# contrib "Bremford, Mike" <mike.bremford@gs.com>
	my $brci = $self->set_clr($self->pick_border_clr($ds));

	# CONTRIB Jeremy Wadsack, shadows
	my $bsd = $self->{shadow_depth} and
		my $bsci = $self->set_clr(_rgb($self->{shadowclr}));

	my @values = $self->{_data}->y_values($ds);

	for (my $i = 0; $i < @values; $i++) 
	{
		my $value = $values[$i];
		next unless defined $value;

		my $bottom = $self->{zeropoint};

		if ($self->{overwrite} == 2 && $ds > 1)
		{
			$value = $self->{_data}->get_y_cumulative($ds, $i);
			my $pvalue = $self->{_data}->get_y_cumulative($ds - 1, $i);
			(undef, $bottom) = $self->val_to_pixel($i + 1, $pvalue, $ds)
		}

		# CONTRIB Jeremy Wadsack
		#
		# cycle_clrs option sets the color based on the point, 
		# not the dataset.
		$dsci = $self->set_clr($self->pick_data_clr($i + 1))
			if $self->{cycle_clrs};
		$brci = $self->set_clr($self->pick_data_clr($i + 1))
			if $self->{cycle_clrs} > 1;

		# get coordinates of top and center of bar
		my ($xp, $t) = $self->val_to_pixel($i + 1, $value, $ds);

		# calculate left and right of bar
		my ($l, $r);

		if (ref $self eq 'GD::Graph::mixed' || $self->{overwrite})
		{
			$l = $xp - _round($self->{x_step}/2) + $bar_s;
			$r = $xp + _round($self->{x_step}/2) - $bar_s;
		}
		else
		{
			$l = $xp 
				- _round($self->{x_step}/2)
				+ _round(($ds - 1) * $self->{x_step}/$self->{_data}->num_sets)
				+ $bar_s;
			$r = $xp 
				- _round($self->{x_step}/2)
				+ _round($ds * $self->{x_step}/$self->{_data}->num_sets)
				- $bar_s;
		}

		# draw the bar
		if ($value >= 0)
		{
			# positive value
			$self->{graph}->filledRectangle(
				$l + $bsd, $t + $bsd, $r + $bsd, $bottom, $bsci
			) if $bsd;
			$self->{graph}->filledRectangle($l, $t, $r, $bottom, $dsci);
			$self->{graph}->rectangle($l, $t, $r, $bottom, $brci) 
				if $r - $l > $self->{accent_treshold};
		}
		else
		{
			# negative value
			$self->{graph}->filledRectangle(
				$l + $bsd, $bottom, $r + $bsd, $t + $bsd, $bsci
			) if $bsd;
			$self->{graph}->filledRectangle($l, $bottom, $r, $t, $dsci);
			$self->{graph}->rectangle($l, $bottom, $r, $t, $brci) 
				if $r - $l > $self->{accent_treshold};
		}
	}

	return $ds;
}

1;
