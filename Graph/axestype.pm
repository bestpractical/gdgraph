#==========================================================================
#			   Copyright (c) 1995-1998 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GD::Graph::axestype.pm
#
# $Id: axestype.pm,v 1.2 1999/12/11 12:50:48 mgjv Exp $
#
#==========================================================================

package GD::Graph::axestype;

use strict;
 
use GD::Graph;
use GD::Graph::utils qw(:all);

@GD::Graph::axestype::ISA = qw( GD::Graph );

use constant PI => 4 * atan2(1,1);

my %Defaults = (
 
	# Set the length for the 'short' ticks on the axes.
	tick_length			=> 4,
 
	# Do you want ticks to span the entire width of the graph?
	long_ticks			=> 0,
 
	# Number of ticks for the y axis
	y_tick_number		=> 5,
	x_tick_number		=> undef,		# CONTRIB Scott Prahl
 
	# Skip every nth label. if 1 will print every label on the axes,
	# if 2 will print every second, etc..
	x_label_skip		=> 1,
	y_label_skip		=> 1,

	# Do we want ticks on the x axis?
	x_ticks				=> 1,
	x_all_ticks			=> 0,

	# Where to place the x and y labels
	x_label_position	=> 3/4,
	y_label_position	=> 1/2,

	# vertical printing of x labels
	x_labels_vertical	=> 0,
 
	# Draw axes as a box? (otherwise just left and bottom)
	box_axis			=> 1,
 
	# Use two different axes for the first and second dataset. The first
	# will be displayed using the left axis, the second using the right
	# axis. You cannot use more than two datasets when this option is on.
	two_axes			=> 0,
 
	# Print values on the axes?
	x_plot_values 		=> 1,
	y_plot_values 		=> 1,
 
	# Space between axis and text
	axis_space			=> 4,
 
	# Do you want bars to be drawn on top of each other, or side by side?
	overwrite 			=> 0,

	# Draw the zero axis in the graph in case there are negative values
	zero_axis			=>	0,

	# Draw the zero axis, but do not draw the bottom axis, in case
	# box-axis == 0
	# This also moves the x axis labels to the zero axis
	zero_axis_only		=>	0,

	# Size of the legend markers
	legend_marker_height	=> 8,
	legend_marker_width		=> 12,
	legend_spacing			=> 4,
	legend_placement		=> 'BC',		# '[B][LCR]'

	# Format of the numbers on the x and y axis
	y_number_format			=> undef,
	x_number_format			=> undef,		# CONTRIB Scott Prahl
);

# PUBLIC
sub plot # (\@data)
{
	my $self = shift;
	my $data = shift;

	$self->init_graph();
	$self->check_data($data);
	$self->setup_text();
	$self->setup_legend();
	$self->setup_coords($data);
	$self->draw_text();
	$self->draw_axes($data);
	$self->draw_ticks($data);
	$self->draw_data($data);
	$self->draw_legend($self->{graph});

	return $self->{graph}->png
}

sub setup_text
{
	my $self = shift;

	$self->{gdta_x_label}->set(colour => $self->{lci});
	$self->{gdta_y_label}->set(colour => $self->{lci});
	$self->{xlfh} = $self->{gdta_x_label}->get('height');
	$self->{ylfh} = $self->{gdta_x_label}->get('height');

	$self->{gdta_x_axis}->set(colour => $self->{alci});
	$self->{gdta_y_axis}->set(colour => $self->{alci});
	$self->{xafh} = $self->{gdta_x_label}->get('height');
	$self->{yafh} = $self->{gdta_x_label}->get('height');

	$self->{gdta_legend}->set(colour => $self->{fgci});
	$self->{gdta_legend}->set_align('top', 'left');
	$self->{lgfh} = $self->{gdta_legend}->get('height');
}

sub set_x_label_font # (fontname)
{
	my $self = shift;
	$self->_set_font('gdta_x_label', @_);
}
sub set_y_label_font # (fontname)
{
	my $self = shift;
	$self->_set_font('gdta_y_label', @_);
}
sub set_x_axis_font # (fontname)
{
	my $self = shift;
	$self->_set_font('gdta_x_axis', @_);
}

sub set_y_axis_font # (fontname)
{
	my $self = shift;
	$self->_set_font('gdta_y_axis', @_);
}

sub set_legend # List of legend keys
{
	my $self = shift;
	$self->set( legend => [@_]);
}

sub set_legend_font # (font name)
{
	my $self = shift;
	$self->_set_font('gdta_legend', @_);
}

# PRIVATE
# called on construction, by new
# use inherited defaults

sub initialise
{
	my $self = shift;

	$self->SUPER::initialise();

	my $key;
	foreach $key (keys %Defaults) 
	{
		$self->set( $key => $Defaults{$key} );
	}

	$self->set_x_label_font(GD::gdSmallFont);
	$self->set_y_label_font(GD::gdSmallFont);
	$self->set_x_axis_font(GD::gdTinyFont);
	$self->set_y_axis_font(GD::gdTinyFont);
	$self->set_legend_font(GD::gdTinyFont);
}

# inherit check_data from GD::Graph

sub setup_coords
{
	my $s = shift;
	my $data = shift;

	# Do some sanity checks
	$s->{two_axes} = 0 if ( $s->{numsets} != 2 || $s->{two_axes} < 0 );
	$s->{two_axes} = 1 if ( $s->{two_axes} > 1 );

	delete $s->{y_label2} unless ($s->{two_axes});

	# Set some heights for text
	$s->set( tfh => 0 ) unless ( $s->{title} );
	$s->set( xlfh => 0 ) unless ( $s->{x_label} );

	if ( ! $s->{y1_label} && $s->{y_label} ) 
	{
		$s->{y1_label} = $s->{y_label};
	}

	$s->set( ylfh1 => $s->{y1_label} ? 1 : 0 );
	$s->set( ylfh2 => $s->{y2_label} ? 1 : 0 );

	$s->set( xafh => 0, xafw => 0 ) unless ($s->{x_plot_values}); 
	$s->set( yafh => 0, yafw => 0 ) unless ($s->{y_plot_values});

	$s->{x_axis_label_height} = $s->get_x_axis_label_height($data);

	my $lbl = ($s->{xlfh} ? 1 : 0) + ($s->{xafh} ? 1 : 0);

	# calculate the top and bottom of the bounding box for the graph
	$s->{bottom} = 
		$s->{height} - $s->{b_margin} - 1 -
		( $s->{xlfh} ? $s->{xlfh} : 0 ) -
		( $s->{x_axis_label_height} ? $s->{x_axis_label_height} : 0) -
		( $lbl ? $lbl * $s->{text_space} : 0 );

	$s->{top} = $s->{t_margin} +
				( $s->{tfh} ? $s->{tfh} + $s->{text_space} : 0 );
	$s->{top} = $s->{yafh}/2 if ( $s->{top} == 0 );

	$s->set_max_min($data);

	# Create the labels for the y_axes, and calculate the max length

	$s->create_y_labels();
	$s->create_x_labels(); # CONTRIB Scott Prahl

	# calculate the left and right of the bounding box for the graph
	#my $ls = $s->{yafw} * $s->{y_label_len}[1];
	my $ls = $s->{y_label_len}[1];
	$s->{left} = $s->{l_margin} +
				 ( $ls ? $ls + $s->{axis_space} : 0 ) +
				 ( $s->{ylfh1} ? $s->{ylfh} + $s->{text_space} : 0 );

	#$ls = $s->{yafw} * $s->{y_label_len}[2] if $s->{two_axes};
	$ls = $s->{y_label_len}[2] if $s->{two_axes};
	$s->{right} = $s->{width} - $s->{r_margin} - 1 -
				  $s->{two_axes} * (
					  ( $ls ? $ls + $s->{axis_space} : 0 ) +
					  ( $s->{ylfh2} ? $s->{ylfh} + $s->{text_space} : 0 )
				  );

	# CONTRIB Scott Prahl
	# make sure that we can generate valid x tick marks
	undef($s->{x_tick_number}) if $s->{numpoints} < 2;
	undef($s->{x_tick_number}) if (
			!defined $s->{x_max} || 
			!defined $s->{x_min} ||
			$s->{x_max} == $s->{x_min}
		);

	# calculate the step size for x data
	# CONTRIB Changes by Scott Prahl
	if (defined $s->{x_tick_number})
	{
		my $delta = ($s->{right}-$s->{left})/($s->{x_max}-$s->{x_min});
		$s->{x_offset} = 
			($s->{true_x_min} - $s->{x_min}) * $delta + $s->{left};
		$s->{x_step} = 
			($s->{true_x_max} - $s->{true_x_min}) * $delta/$s->{numpoints};
	}
	else
	{
		$s->{x_step} = ($s->{right} - $s->{left})/($s->{numpoints} + 2);
		$s->{x_offset} = $s->{left};
	}

	# get the zero axis level
	my $dum;
	($dum, $s->{zeropoint}) = $s->val_to_pixel(0, 0, 1);

	# Check the size
	die "Vertical Png size too small"
		if ( ($s->{bottom} - $s->{top}) <= 0 );

	die "Horizontal Png size too small"	
		if ( ($s->{right} - $s->{left}) <= 0 );

	# set up the data colour list if it doesn't exist yet.
	$s->set( 
		dclrs => [ qw( lred lgreen lblue lyellow lpurple cyan lorange )] 
	) unless ( exists $s->{dclrs} );

	# More sanity checks
	$s->{x_label_skip} = 1 		if ( $s->{x_label_skip} < 1 );
	$s->{y_label_skip} = 1 		if ( $s->{y_label_skip} < 1 );
	$s->{y_tick_number} = 1		if ( $s->{y_tick_number} < 1 );
}

sub create_y_labels
{
	my $s = shift;

	$s->{y_label_len}[1] = 0;
	$s->{y_label_len}[2] = 0;

	my $t;
	foreach $t (0 .. $s->{y_tick_number})
	{
		my $a;
		foreach $a (1 .. ($s->{two_axes} + 1))
		{
			my $label = 
				$s->{y_min}[$a] +
				$t *
				($s->{y_max}[$a] - $s->{y_min}[$a])/$s->{y_tick_number};
			
			$s->{y_values}[$a][$t] = $label;

			if (defined $s->{y_number_format})
			{
				if (ref $s->{y_number_format} eq 'CODE')
				{
					$label = &{$s->{y_number_format}}($label);
				}
				else
				{
					$label = sprintf($s->{y_number_format}, $label);
				}
			}
			
			$s->{gdta_y_label}->set_text("$label");
			my $len = $s->{gdta_y_label}->get('width');

			#my $len = length($label);

			$s->{y_labels}[$a][$t] = $label;

			($len > $s->{y_label_len}[$a]) and 
				$s->{y_label_len}[$a] = $len;
		}
	}
}

# CONTRIB Scott Prahl
sub create_x_labels
{
	my $s = shift;
	return unless defined($s->{x_tick_number});

	$s->{x_label_len} = 0;

	my $t;
	foreach $t (0..$s->{x_tick_number})
	{
		my $label =
			$s->{x_min} +
			$t * ($s->{x_max} - $s->{x_min})/$s->{x_tick_number};

		$s->{x_values}[$t] = $label;

		if (defined $s->{x_number_format})
		{
			if (ref $s->{x_number_format} eq 'CODE')
			{
				$label = &{$s->{x_number_format}}($label);
			}
			else
			{
				$label = sprintf($s->{x_number_format}, $label);
			}
		}

		$s->{gdta_x_label}->set_text($label);
		my $len = $s->{gdta_x_label}->get('width');
		#my $len = length($label);

		$s->{x_labels}[$t] = $label;

		($len > $s->{x_label_len}) and $s->{x_label_len} = $len;
	}
}

sub get_x_axis_label_height
{
	my $s = shift;
	my $data = shift;

	return $s->{xafh} unless $s->{x_labels_vertical};

	my $len = 0;
	my $labels = $data->[0];
	my $label;
	foreach $label (@$labels)
	{
		$s->{gdta_x_axis}->set_text($label);
		my $llen = $s->{gdta_x_axis}->get('width');
		($llen > $len) and $len = $llen;
	}
	return $len
}

# inherit open_graph from GD::Graph

sub draw_text # GD::Image
{
	my $s = shift;

	if ($s->{title})
	{
		my $xc = $s->{left} + ($s->{right} - $s->{left})/2;
		$s->{gdta_title}->set_align('top', 'center');
		$s->{gdta_title}->set_text($s->{title});
		$s->{gdta_title}->draw($xc, $s->{t_margin});
	}

	# X label
	if (exists $s->{x_label}) 
	{
		$s->{gdta_x_label}->set_text($s->{x_label});
		$s->{gdta_x_label}->set_align('bottom', 'left');
		my $tx = $s->{left} +
			$s->{x_label_position} * ($s->{right} - $s->{left}) - 
			$s->{x_label_position} * $s->{gdta_x_label}->get('width');
		$s->{gdta_x_label}->draw($tx, $s->{height} - $s->{b_margin});
	}

	# Y labels
	if (exists $s->{y1_label}) 
	{
		$s->{gdta_y_label}->set_text($s->{y1_label});
		$s->{gdta_y_label}->set_align('top', 'left');
		my $tx = $s->{l_margin};
		my $ty = $s->{bottom} -
			$s->{y_label_position} * ($s->{bottom} - $s->{top}) + 
			$s->{y_label_position} * $s->{gdta_y_label}->get('width');
		$s->{gdta_y_label}->draw($tx, $ty, PI/2);
	}
	if ( $s->{two_axes} && exists $s->{y2_label} ) 
	{
		$s->{gdta_y_label}->set_text($s->{y2_label});
		$s->{gdta_y_label}->set_align('top', 'left');
		my $tx = $s->{width} - $s->{r_margin} -
			$s->{gdta_y_label}->get('height');
		my $ty = $s->{bottom} -
			$s->{y_label_position} * ($s->{bottom} - $s->{top}) + 
			$s->{y_label_position} * $s->{gdta_y_label}->get('width');
		$s->{gdta_y_label}->draw($tx, $ty, PI/2);
	}
}

sub draw_axes # GD::Image
{
	my $s = shift;
	my $d = shift;
	my $g = $s->{graph};

	my ($l, $r, $b, $t) = 
		( $s->{left}, $s->{right}, $s->{bottom}, $s->{top} );

	if ( $s->{box_axis} ) 
	{
		$g->rectangle($l, $t, $r, $b, $s->{fgci});
	}
	else
	{
		$g->line($l, $t, $l, $b, $s->{fgci});
		$g->line($l, $b, $r, $b, $s->{fgci}) 
			unless ($s->{zero_axis_only});
		$g->line($r, $b, $r, $t, $s->{fgci}) 
			if ($s->{two_axes});
	}

	if ($s->{zero_axis} or $s->{zero_axis_only})
	{
		my ($x, $y) = $s->val_to_pixel(0, 0, 1);
		$g->line($l, $y, $r, $y, $s->{fgci});
	}
}

#
# Ticks and values for y axes
#
sub draw_y_ticks # GD::Image, \@data
{
	my $s = shift;
	my $d = shift;

	#
	# Ticks and values for y axes
	#
	my $t;
	foreach $t (0 .. $s->{y_tick_number}) 
	{
		my $a;
		foreach $a (1 .. ($s->{two_axes} + 1)) 
		{
			my $value = $s->{y_values}[$a][$t];
			my $label = $s->{y_labels}[$a][$t];
			
			my ($x, $y) = $s->val_to_pixel(0, $value, $a);
			#my ($x, $y) = $s->val_to_pixel( 
			#	($a-1) * ($s->{numpoints} + 2), 
			#	$value, 
			#	$a 
			#);

			$x = ($a == 1) ? $s->{left} : $s->{right};

			if ($s->{long_ticks}) 
			{
				$s->{graph}->line( 
					$x, $y, 
					$x + $s->{right} - $s->{left}, $y, 
					$s->{fgci} 
				) unless ($a-1);
			} 
			else 
			{
				$s->{graph}->line( 
					$x, $y, 
					$x + (3 - 2 * $a) * $s->{tick_length}, $y, 
					$s->{fgci} 
				);
			}

			next 
				if ( $t % ($s->{y_label_skip}) || ! $s->{y_plot_values} );

			$s->{gdta_y_axis}->set_text($label);
			$s->{gdta_y_axis}->set_align('center', 
				$a == 1 ? 'right' : 'left');
			$x -= (3 - 2 * $a) * $s->{axis_space};
			$s->{gdta_y_axis}->draw($x, $y);
		}
	}
}

#
# Ticks and values for x axes
#
sub draw_x_ticks # GD::Image, \@data
{
	my $s = shift;
	my $d = shift;

	my $i;
	for $i (0 .. $s->{numpoints}) 
	{
		my ($x, $y) = $s->val_to_pixel($i + 1, 0, 1);

		$y = $s->{bottom} unless $s->{zero_axis_only};

		next if (!$s->{x_all_ticks} and 
				$i%($s->{x_label_skip}) and 
				$i != $s->{numpoints} 
			);

		if ($s->{x_ticks})
		{
			if ($s->{long_ticks})
			{
				$s->{graph}->line($x, $s->{bottom}, $x, $s->{top},
					$s->{fgci});
			}
			else
			{
				$s->{graph}->line($x, $y, $x, $y - $s->{tick_length},
					$s->{fgci});
			}
		}

		next if ($i%($s->{x_label_skip}) and $i != $s->{numpoints});

		$s->{gdta_x_axis}->set_text($d->[0][$i]);

		if ($s->{x_labels_vertical})
		{
			$s->{gdta_x_axis}->set_align('center', 'right');
			my $yt = $y + $s->{text_space}/2;
			$s->{gdta_x_axis}->draw($x, $yt, PI/2);
			#$x -= $s->{xafw};
			#my $yt = 
			#	$y + $s->{text_space}/2 + $s->{xafw} * length($d->[0][$i]);
			#$g->stringUp($s->{xaf}, $x, $yt, $d->[0][$i], $s->{alci});
		}
		else
		{
			$s->{gdta_x_axis}->set_align('top', 'center');
			my $yt = $y + $s->{text_space}/2;
			$s->{gdta_x_axis}->draw($x, $yt);
			#$x -= $s->{xafw} * length($d->[0][$i])/2;
			#my $yt = $y + $s->{text_space}/2;
			#$g->string($s->{xaf}, $x, $yt, $d->[0][$i], $s->{alci});
		}
	}
}


# CONTRIB Scott Prahl
# Assume x array contains equally spaced x-values
# and generate an appropriate axis
#
sub draw_x_ticks_number # GD::Image, \@data
{
	my $s = shift;
	my $d = shift;

	my $i;
	for $i (0 .. $s->{x_tick_number})
	{
		my $value = $s->{numpoints}
					* ($s->{x_values}[$i] - $s->{true_x_min})
					/ ($s->{true_x_max} - $s->{true_x_min});

		my $label = $s->{x_values}[$i];

		my ($x, $y) = $s->val_to_pixel($value + 1, 0, 1);

		$y = $s->{bottom} unless $s->{zero_axis_only};

		if ($s->{x_ticks})
		{
			if ($s->{long_ticks})
			{
				$s->{graph}->line($x, $s->{bottom}, $x, $s->{top},$s->{fgci});
			}
			else
			{
				$s->{graph}->line( $x, $y, $x, $y - $s->{tick_length}, $s->{fgci} );
			}
		}

		next
			if ( $i%($s->{x_label_skip}) and $i != $s->{x_tick_number} );

		$s->{gdta_x_axis}->set_text($label);

		if ($s->{x_labels_vertical})
		{
			$s->{gdta_x_axis}->set_align('center', 'right');
			my $yt = $y + $s->{text_space}/2;
			$s->{gdta_x_axis}->draw($x, $yt, PI/2);

			#$x -= $s->{xafw};
			#my $yt =
			#	$y + $s->{text_space}/2 + $s->{xafw} * length($d->[0][$i]);
			#$s->{graph}->stringUp($s->{xaf}, $x, $yt, $label, $s->{alci});
		}
		else
		{
			$s->{gdta_x_axis}->set_align('top', 'center');
			my $yt = $y + $s->{text_space}/2;
			$s->{gdta_x_axis}->draw($x, $yt);

#			$x -= $s->{xafw} * length($$d[0][$i])/2;
			#$x -=  length($d->[0][$i])/2;
			#my $yt = $y + $s->{text_space}/2;
			#$s->{graph}->string($s->{xaf}, $x, $yt, $label, $s->{alci});
		}
	}
}

sub draw_ticks # GD::Image, \@data
{
	my $s = shift;
	my $d = shift;

	$s->draw_y_ticks($d);

	return unless ( $s->{x_plot_values} );

	if (defined $s->{x_tick_number})
	{
		$s->draw_x_ticks_number($d);
	}
	else
	{
		$s->draw_x_ticks($d);
	}
}

sub draw_data # GD::Image, \@data
{
	my $s = shift;
	my $d = shift;

	my $ds;
	foreach $ds (1 .. $s->{numsets}) 
	{
		$s->draw_data_set($d->[$ds], $ds);
	}
}

# draw_data_set is in sub classes

sub draw_data_set
{
	# ABSTRACT
	my $s = shift;
	$s->die_abstract( "sub draw_data missing, ")
}

# Figure out the maximum values for the vertical exes, and calculate
# a more or less sensible number for the tops.

sub set_max_min
{
	my $s = shift;
	my $d = shift;

	my @max_min;

	# First, calculate some decent values

	if ( $s->{two_axes} ) 
	{
		my $i;
		for $i (1 .. 2) 
		{
			my $true_y_min = get_min_y(@{$$d[$i]});
			my $true_y_max = get_max_y(@{$$d[$i]});
			($s->{y_min}[$i], $s->{y_max}[$i], $s->{y_tick_number}) =
				_best_ends($true_y_min, $true_y_max, $s->{y_tick_number});
		}
	} 
	else 
	{
		my ($true_y_min, $true_y_max) = $s->get_max_min_y_all($d);
		($s->{y_min}[1], $s->{y_max}[1], $s->{y_tick_number}) =
			_best_ends($true_y_min, $true_y_max, $s->{y_tick_number});
	}

	if (defined( $s->{x_tick_number} ))
	{
		$s->{true_x_min} = get_min_y(@{$d->[0]});
		$s->{true_x_max} = get_max_y(@{$d->[0]});

		($s->{x_min}, $s->{x_max}, $s->{x_tick_number}) =
			_best_ends( $s->{true_x_min}, $s->{true_x_max}, 
						$s->{x_tick_number});
	}

	# Make sure bars and area always have a zero offset

	if (ref($s) eq 'GD::Graph::bars' or ref($s) eq 'GD::Graph::area')
	{
		$s->{y_min}[1] = 0 if $s->{y_min}[1] > 0;
		$s->{y_min}[2] = 0 if $s->{y_min}[2] && $s->{y_min}[2] > 0;
	}

	# Overwrite these with any user supplied ones

	$s->{y_min}[1] = $s->{y_min_value}  if defined $s->{y_min_value};
	$s->{y_min}[2] = $s->{y_min_value}  if defined $s->{y_min_value};

	$s->{y_max}[1] = $s->{y_max_value}  if defined $s->{y_max_value};
	$s->{y_max}[2] = $s->{y_max_value}  if defined $s->{y_max_value};

	$s->{y_min}[1] = $s->{y1_min_value} if defined $s->{y1_min_value};
	$s->{y_max}[1] = $s->{y1_max_value} if defined $s->{y1_max_value};

	$s->{y_min}[2] = $s->{y2_min_value} if defined $s->{y2_min_value};
	$s->{y_max}[2] = $s->{y2_max_value} if defined $s->{y2_max_value};

	$s->{x_min}    = $s->{x_min_value}  if defined $s->{x_min_value};
	$s->{x_max}    = $s->{x_max_value}  if defined $s->{x_max_value};

	# Check to see if we have sensible values

	if ( $s->{two_axes} ) 
	{
		my $i;
		for $i (1 .. 2)
		{
			die "Minimum for y" . $i . " too large\n"
				if ( $s->{y_min}[$i] > get_min_y(@{$d->[$i]}) );
			die "Maximum for y" . $i . " too small\n"
				if ( $s->{y_max}[$i] < get_max_y(@{$d->[$i]}) );
		}
	} 
#	else 
#	{
#		die "Minimum for y too large\n"
#			if ( $s->{y_min}[1] > $max_min[1] );
#		die "Maximum for y too small\n"
#			if ( $s->{y_max}[1] < $max_min[0] );
#	}
}

# return maximum value from an array

sub get_max_y # array
{
	my $max = undef;

	my $i;
	foreach $i (@_) 
	{ 
		next unless defined $i;
		$max = (defined($max) && $max >= $i) ? $max : $i; 
	}

	return $max
}

sub get_min_y # array
{
	my $min = undef;

	my $i;
	foreach $i (@_) 
	{ 
		next unless defined $i;
		$min = ( defined($min) and $min <= $i) ? $min : $i;
	}

	return $min
}

# get maximum y value from the whole data set

sub get_max_min_y_all # \@data
{
	my $s = shift;
	my $d = shift;

	my $max = undef;
	my $min = undef;

	if ($s->{overwrite} == 2) 
	{
		my $i;
		for $i (0 .. $s->{numpoints}) 
		{
			my $sum = 0;

			my $j;
			for $j (1 .. $s->{numsets}) 
			{ 
				$sum += $d->[$j][$i]; 
			}

			$max = _max( $max, $sum );
			$min = _min( $min, $sum );
		}
	}
	else 
	{
		my $i;
		for $i ( 1 .. $s->{numsets} ) 
		{
			$max = _max( $max, get_max_y(@{$d->[$i]}) );
			$min = _min( $min, get_min_y(@{$d->[$i]}) );
		}
	}

	return ($max, $min)
}


# CONTRIB Scott Prahl
#
# Calculate best endpoints and number of intervals for an axis and
# returns ($nice_min, $nice_max, $n), where $n is the number of
# intervals and
#
#    $nice_min <= $min < $max <= $nice_max
#
# Usage:
#		($nmin,$nmax,$nint) = _best_ends(247, 508);
#		($nmin,$nmax) = _best_ends(247, 508, 5); 
# 			use 5 intervals
#		($nmin,$nmax,$nint) = _best_ends(247, 508, 4..7);	
# 			best of 4,5,6,7 intervals

sub _best_ends 
{
	my ($min, $max, @n) = @_;
	my ($best_min, $best_max, $best_num) = ($min, $max, 1);

	# fix endpoints, fix intervals, set defaults
	($min, $max) = ($max, $min) if ($min > $max);
	($min, $max) = ($min) ? ($min * 0.5, $min * 1.5) : (-1,1) 
		if ($max == $min);

	@n = (3..6) if (@n <= 0 || $n[0] =~ /auto/i);

	my $best_fit = 1e30;
	my $range = $max - $min;

	# create array of interval sizes
	my $s = 1;
	while ($s < $range) { $s *= 10 }
	while ($s > $range) { $s /= 10 }
	my @step = map {$_ * $s} (0.2, 0.5, 1, 2, 5);

	for (@n) 
	{								
		# Try all numbers of intervals
		my $n = $_;
		next if ($n < 1);

		for (@step) 
		{
			next if ($n != 1) && ($_ < $range/$n); # $step too small

			my $nice_min   = $_ * int($min/$_);
			$nice_min  -= $_ if ($nice_min > $min);
			my $nice_max   = ($n == 1) 
				? $_ * int($max/$_ + 1) 
				: $nice_min + $n * $_;
			my $nice_range = $nice_max - $nice_min;

			next if ($nice_max < $max);	# $nice_min too small
			next if ($best_fit <= $nice_range - $range); # not closer fit

			$best_min = $nice_min;
			$best_max = $nice_max;
			$best_fit = $nice_range - $range;
			$best_num = $n;
		}
	}
	return ($best_min, $best_max, $best_num)
}

# Convert value coordinates to pixel coordinates on the canvas.

sub val_to_pixel	# ($x, $y, $i) in real coords ($Dataspace), 
{						# return [x, y] in pixel coords
	my $s = shift;
	my ($x, $y, $i) = @_;

	my $y_min = 
		($s->{two_axes} && $i == 2) ? $s->{y_min}[2] : $s->{y_min}[1];

	my $y_max = 
		($s->{two_axes} && $i == 2) ? $s->{y_max}[2] : $s->{y_max}[1];

	my $y_step = abs(($s->{bottom} - $s->{top})/($y_max - $y_min));

	return ( 
		_round( ($s->{x_tick_number} ? $s->{x_offset} : $s->{left}) 
					+ $x * $s->{x_step} ),
		_round( $s->{bottom} - ($y - $y_min) * $y_step )
	)
}

#
# Legend
#

sub setup_legend
{
	my $s = shift;

	return unless defined($s->{legend});

	my $maxlen = 0;
	my $num = 0;

	# Save some variables
	$s->{r_margin_abs} = $s->{r_margin};
	$s->{b_margin_abs} = $s->{b_margin};

	my $legend;
	foreach $legend (@{$s->{legend}})
	{
		if (defined($legend) and $legend ne "")
		{
			$s->{gdta_legend}->set_text($legend);
			my $len = $s->{gdta_legend}->get('width');
			$maxlen = ($maxlen > $len) ? $maxlen : $len;
			$num++;
		}
		last if ($num >= $s->{numsets});
	}

	$s->{lg_num} = $num;

	# calculate the height and width of each element

	my $legend_height = _max($s->{lgfh}, $s->{legend_marker_height});

	$s->{lg_el_width} = 
		$maxlen + $s->{legend_marker_width} + 
		3 * $s->{legend_spacing};
	$s->{lg_el_height} = $legend_height + 2 * $s->{legend_spacing};

	my ($lg_pos, $lg_align) = split(//, $s->{legend_placement});

	if ($lg_pos eq 'R')
	{
		# Always work in one column
		$s->{lg_cols} = 1;
		$s->{lg_rows} = $num;

		# Just for completeness, might use this in later versions
		$s->{lg_x_size} = $s->{lg_cols} * $s->{lg_el_width};
		$s->{lg_y_size} = $s->{lg_rows} * $s->{lg_el_height};

		# Adjust the right margin for the rest of the graph
		$s->{r_margin} += $s->{lg_x_size};

		# Set the x starting point
		$s->{lg_xs} = $s->{width} - $s->{r_margin};

		# Set the y starting point, depending on alignment
		if ($lg_align eq 'T')
		{
			$s->{lg_ys} = $s->{t_margin};
		}
		elsif ($lg_align eq 'B')
		{
			$s->{lg_ys} = $s->{height} - $s->{b_margin} - $s->{lg_y_size};
		}
		else # default 'C'
		{
			my $height = $s->{height} - $s->{t_margin} - $s->{b_margin};

			$s->{lg_ys} = 
				int($s->{t_margin} + $height/2 - $s->{lg_y_size}/2) ;
		}
	}
	else # 'B' is the default
	{
		# What width can we use
		my $width = $s->{width} - $s->{l_margin} - $s->{r_margin};

		(!defined($s->{lg_cols})) and 
			$s->{lg_cols} = int($width/$s->{lg_el_width});
		
		$s->{lg_cols} = _min($s->{lg_cols}, $num);

		$s->{lg_rows} = 
			int($num/$s->{lg_cols}) + (($num % $s->{lg_cols}) ? 1 : 0);

		$s->{lg_x_size} = $s->{lg_cols} * $s->{lg_el_width};
		$s->{lg_y_size} = $s->{lg_rows} * $s->{lg_el_height};

		# Adjust the bottom margin for the rest of the graph
		$s->{b_margin} += $s->{lg_y_size};

		# Set the y starting point
		$s->{lg_ys} = $s->{height} - $s->{b_margin};

		# Set the x starting point, depending on alignment
		if ($lg_align eq 'R')
		{
			$s->{lg_xs} = $s->{width} - $s->{r_margin} - $s->{lg_x_size};
		}
		elsif ($lg_align eq 'L')
		{
			$s->{lg_xs} = $s->{l_margin};
		}
		else # default 'C'
		{
			$s->{lg_xs} =  
				int($s->{l_margin} + $width/2 - $s->{lg_x_size}/2);
		}

	}
}

sub draw_legend # (GD::Image)
{
	my $s = shift;
	my $g = shift;

	return unless defined($s->{legend});

	my $xl = $s->{lg_xs} + $s->{legend_spacing};
	my $y = $s->{lg_ys} + $s->{legend_spacing} - 1;
	
	my $i = 0;
	my $row = 1;
	my $x = $xl;	# start position of current element

	my $legend;
	foreach $legend (@{$s->{legend}})
	{
		$i++;
		last if ($i > $s->{numsets});

		my $xe = $x;	# position within an element

		next unless (defined($legend) && $legend ne "");

		$s->draw_legend_marker($g, $i, $xe, $y);

		$xe += $s->{legend_marker_width} + $s->{legend_spacing};
		my $ys = int($y + $s->{lg_el_height}/2 - $s->{lgfh}/2);

		$s->{gdta_legend}->set_text($legend);
		$s->{gdta_legend}->draw($xe, $ys);
		#$g->string($s->{lgf}, $xe, $ys, $legend, $s->{fgci});

		$x += $s->{lg_el_width};

		if (++$row > $s->{lg_cols})
		{
			$row = 1;
			$y += $s->{lg_el_height};
			$x = $xl;
		}
	}
}

# This will be virtual; every sub class should define their own
# if this one doesn't suffice
sub draw_legend_marker # (GD::Image, data_set_number, x, y)
{
	my $s = shift;
	my $g = shift;
	my $n = shift;
	my $x = shift;
	my $y = shift;

	my $ci = $s->set_clr($s->pick_data_clr($n));

	$y += int($s->{lg_el_height}/2 - $s->{legend_marker_height}/2);

	$g->filledRectangle(
		$x, $y, 
		$x + $s->{legend_marker_width}, $y + $s->{legend_marker_height},
		$ci
	);

	$g->rectangle(
		$x, $y, 
		$x + $s->{legend_marker_width}, $y + $s->{legend_marker_height},
		$s->{acci}
	);
}

1;
