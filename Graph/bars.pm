#==========================================================================
#			   Copyright (c) 1995-1998 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GD::Graph::bars.pm
#
# $Id: bars.pm,v 1.20 2000/10/07 04:06:22 mgjv Exp $
#
#==========================================================================
 
package GD::Graph::bars;

$GD::Graph::bars::VERSION = '$Revision: 1.20 $' =~ /\s([\d.]+)/;

use strict;

use GD::Graph::axestype;
use GD::Graph::utils qw(:all);
use GD::Graph::colour qw(:colours);

@GD::Graph::bars::ISA = qw(GD::Graph::axestype);

use constant PI => 4 * atan2(1,1);

sub initialise
{
	my $self = shift;
	$self->SUPER::initialise();
	$self->set(correct_width => 1);
}

sub draw_data
{
	my $self = shift;

	$self->SUPER::draw_data() or return;

	# redraw the 'zero' axis
	$self->{graph}->line( 
		$self->{left}, $self->{zeropoint}, 
		$self->{right}, $self->{zeropoint}, 
		$self->{fgci} );
	
	return $self;
}

sub draw_data_set
{
	my $self = shift;
	my $ds = shift;

	my $bar_s = $self->{bar_spacing}/2;

	# Pick a data colour
	my $dsci = $self->set_clr($self->pick_data_clr($ds));
	# contrib "Bremford, Mike" <mike.bremford@gs.com>
	my $brci = $self->set_clr($self->pick_border_clr($ds));

	# CONTRIB Jeremy Wadsack, shadows
	my $bsd = $self->{shadow_depth} and
		my $bsci = $self->set_clr(_rgb($self->{shadowclr}));

	my @values = $self->{_data}->y_values($ds) or
		return $self->_set_error("Impossible illegal data set: $ds",
			$self->{_data}->error);

	for (my $i = 0; $i < @values; $i++) 
	{
		my $value = $values[$i];
		next unless defined $value;

		my $bottom = $self->_get_bottom($ds, $i);
		$value = $self->{_data}->get_y_cumulative($ds, $i)
			if ($self->{cumulate});

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
			$l = $xp - $self->{x_step}/2 + $bar_s + 1;
			$r = $xp + $self->{x_step}/2 - $bar_s;
		}
		else
		{
			$l = $xp 
				- $self->{x_step}/2
				+ ($ds - 1) * $self->{x_step}/$self->{_data}->num_sets
				+ $bar_s + 1;
			$r = $xp 
				- $self->{x_step}/2
				+ $ds * $self->{x_step}/$self->{_data}->num_sets
				- $bar_s;
		}

		# draw the bar
		if ($value >= 0)
		{
			# positive value
			$self->{graph}->filledRectangle(
				$l + $bsd, $t + $bsd, $r + $bsd, $bottom, $bsci
			) if $bsd;
			$self->{graph}->filledRectangle($l, $t, $r, $bottom, $dsci)
				if defined $dsci;
			$self->{graph}->rectangle($l, $t, $r, $bottom, $brci) 
				if defined $brci && $r - $l > $self->{accent_treshold};

			$self->{_hotspots}->[$ds]->[$i] = ['rect', $l, $t, $r, $bottom]
		}
		else
		{
			# negative value
			$self->{graph}->filledRectangle(
				$l + $bsd, $bottom, $r + $bsd, $t + $bsd, $bsci
			) if $bsd;
			$self->{graph}->filledRectangle($l, $bottom, $r, $t, $dsci)
				if defined $dsci;
			$self->{graph}->rectangle($l, $bottom, $r, $t, $brci) 
				if defined $brci && $r - $l > $self->{accent_treshold};

			$self->{_hotspots}->[$ds]->[$i] = ['rect', $l, $bottom, $r, $t]
		}
	}

	return $ds;
}

sub draw_values
{
	my $self = shift;
	
	return $self unless $self->{show_values};
	
	my $text_angle = $self->{values_vertical} ? PI/2 : 0;

	for (my $dsn = 1; $dsn <= $self->{_data}->num_sets; $dsn++)
	{
		my @values = $self->{_data}->y_values($dsn) or
			return $self->_set_error("Impossible illegal data set: $dsn",
				$self->{_data}->error);
		my @display = $self->{show_values}->y_values($dsn) or next;

		for (my $i = 0; $i < @values; $i++)
		{
			next unless defined $display[$i];
			my ($xp, $yp);
			if (defined($self->{x_min_value}) && defined($self->{x_max_value}))
			{
				($xp, $yp) = $self->val_to_pixel(
					$self->{_data}->get_x($i), $values[$i], $dsn);
			}
			else	
			{
				($xp, $yp) = $self->val_to_pixel($i+1, $values[$i], $dsn);
			}
			$yp -= $self->{values_space};

			my $value = $display[$i];
			if (defined $self->{values_format})
			{
				$value = ref $self->{values_format} eq 'CODE' ?
					&{$self->{values_format}}($value) :
					sprintf($self->{values_format}, $value);
			}

			unless ($self->{overwrite})
			{
				$xp = $xp 
					- $self->{x_step}/2
					+ ($dsn - 0.5) * $self->{x_step}/$self->{_data}->num_sets;
			}

			$self->{gdta_values}->set_text($value);
			$self->{gdta_values}->draw($xp, $yp, $text_angle);
		}
	}

	return $self
}

"Just another true value";
