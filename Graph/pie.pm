#==========================================================================
#			   Copyright (c) 1995-1998 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GD::Graph::pie.pm
#
# $Id: pie.pm,v 1.8 2000/01/27 11:12:11 mgjv Exp $
#
#==========================================================================

package GD::Graph::pie;

use strict;

use constant PI => 4 * atan2(1,1);

use GD;
use GD::Graph;
use GD::Graph::utils qw(:all);
use GD::Graph::colour qw(:colours :lists);
use GD::Text::Align;
use Carp;

@GD::Graph::pie::ISA = qw( GD::Graph );

my $ANGLE_OFFSET = 90;

my %Defaults = (
 
	# Set the height of the pie.
	# Because of the dependency of this on runtime information, this
	# is being set in GD::Graph::pie::initialise
 
	#   pie_height => _round(0.1*${'width'}),
	pie_height 	=> undef,
 
	# Do you want a 3D pie?
	'3d'        => 1,
 
	# The angle at which to start the first data set
	# 0 is at the front/bottom
	start_angle => 0,

	# Angle below which a label on a pie slice is suppressed.
	suppress_angle => 0,	# CONTRIB idea ryan <xomina@bitstream.net>

	# and some public attributes without defaults
	label		=> undef,
);

# PRIVATE
sub _has_default { 
	my $self = shift;
	my $attr = shift || return;
	exists $Defaults{$attr} || $self->SUPER::_has_default($attr);
}

sub initialise
{
	my $self = shift;
	$self->SUPER::initialise();
	while (my($key, $val) = each %Defaults)
		{ $self->{$key} = $val }
	$self->set( pie_height => _round(0.1 * $self->{height}) );
	$self->set_value_font(gdTinyFont);
	$self->set_label_font(gdSmallFont);
}

# PUBLIC methods, documented in pod
sub plot # (\@data)
{
	my $self = shift;
	my $data = shift;

	$self->init_graph($self->{graph});
	$self->check_data($data);
	$self->setup_text();
	$self->setup_coords();
	$self->draw_text();
	$self->draw_pie($self->{graph});
	$self->draw_data($data, $self->{graph});

	return $self->{graph};
}

sub set_label_font # (fontname)
{
	my $self = shift;
	$self->_set_font('gdta_label', @_) or return;
	$self->{gdta_label}->set_align('bottom', 'center');
}

sub set_value_font # (fontname)
{
	my $self = shift;
	$self->_set_font('gdta_value', @_) or return;
	$self->{gdta_value}->set_align('center', 'center');
}

# Inherit defaults() from GD::Graph

# inherit checkdata from GD::Graph

# Setup the coordinate system and colours, calculate the
# relative axis coordinates in respect to the canvas size.

sub setup_coords()
{
	my $s = shift;

	# Make sure we're not reserving space we don't need.
	$s->{'3d'} = 0 				if     $s->{pie_height} <= 0;
	$s->set(pie_height => 0)	unless $s->{'3d'};

	my $tfh = $s->{title} ? $s->{gdta_title}->get('height') : 0;
	my $lfh = $s->{label} ? $s->{gdta_label}->get('height') : 0;

	# Calculate the bounding box for the pie, and
	# some width, height, and centre parameters
	$s->{bottom} = 
		$s->{height} - $s->{pie_height} - $s->{b_margin} -
		( $lfh ? $lfh + $s->{text_space} : 0 );

	$s->{top} = 
		$s->{t_margin} + ( $tfh ? $tfh + $s->{text_space} : 0 );

	$s->{left} = $s->{l_margin};

	$s->{right} = $s->{width} - $s->{r_margin};

	( $s->{w}, $s->{h} ) = 
		( $s->{right}-$s->{left}, $s->{bottom}-$s->{top} );

	( $s->{xc}, $s->{yc} ) = 
		( ($s->{right}+$s->{left})/2, ($s->{bottom}+$s->{top})/2 );

	croak "Vertical size too small" 
		if ( ($s->{bottom} - $s->{top}) <= 0 );
	croak "Horizontal size too small"
		if ( ($s->{right} - $s->{left}) <= 0 );
}

# inherit open_graph from GD::Graph

# Setup the parameters for the text elements
sub setup_text
{
	my $s = shift;

	if ( $s->{title} ) 
	{
		#print "'$s->{title}' at ($s->{xc},$s->{t_margin})\n";
		$s->{gdta_title}->set(colour => $s->{tci});
		$s->{gdta_title}->set_text($s->{title});
	}

	if ( $s->{label} ) 
	{
		$s->{gdta_label}->set(colour => $s->{lci});
		$s->{gdta_label}->set_text($s->{label});
	}

	$s->{gdta_value}->set(colour => $s->{alci});
}

# Put the text on the canvas.
sub draw_text # (GD::Image)
{
	my $s = shift;

	$s->{gdta_title}->draw($s->{xc}, $s->{t_margin}) 
		if $s->{title}; 

	$s->{gdta_label}->draw($s->{xc}, $s->{height} - $s->{b_margin})
		if $s->{label};
}

# draw the pie, without the data slices
sub draw_pie # (GD::Image)
{
	my $s = shift;
	my $g = $s->{graph};

	my $left = $s->{xc} - $s->{w}/2;

	$s->{graph}->arc(
		$s->{xc}, $s->{yc}, 
		$s->{w}, $s->{h},
		0, 360, $s->{acci}
	);

	$s->{graph}->arc(
		$s->{xc}, $s->{yc} + $s->{pie_height}, 
		$s->{w}, $s->{h},
		0, 180, $s->{acci}
	) if ( $s->{'3d'} );

	$s->{graph}->line(
		$left, $s->{yc},
		$left, $s->{yc} + $s->{pie_height}, 
		$s->{acci}
	);

	$s->{graph}->line(
		$left + $s->{w}, $s->{yc},
		$left + $s->{w}, $s->{yc} + $s->{pie_height}, 
		$s->{acci}
	);
}

# Draw the data slices

sub draw_data # (\@data, GD::Image)
{
	my $s = shift;
	my $data = shift;

	my $total = 0;
	my $j = 1; 						# for now, only one pie..

	my $i;
	for $i ( 0 .. $s->{numpoints} ) 
	{ 
		$total += $data->[$j][$i]; 
	}
	croak "no Total" unless $total;

	my $ac = $s->{acci};			# Accent colour
	my $pb = $s->{start_angle};

	my $val = 0;

	for $i (0 .. $s->{numpoints}) 
	{
		# Set the data colour
		my $dc = $s->set_clr_uniq($s->pick_data_clr($i + 1));

		# Set the angles of the pie slice
		# Angle 0 faces down, positive angles are clockwise 
		# from there.
		#         ---
		#        /   \
		#        |    |
		#        \ | /
		#         ---
		#          0
		# $pa/$pb include the start_angle (so if start_angle
		# is 90, there will be no pa/pb < 90.
		my $pa = $pb;
		$pb += my $slice_angle = 360 * $data->[1][$i]/$total;

		# Calculate the end points of the lines at the boundaries of
		# the pie slice
		my ($xe, $ye) = cartesian(
				$s->{w}/2, $pa, 
				$s->{xc}, $s->{yc}, $s->{h}/$s->{w}
			);

		$s->{graph}->line($s->{xc}, $s->{yc}, $xe, $ye, $ac);

		# Draw the lines on the front of the pie
		$s->{graph}->line($xe, $ye, $xe, $ye + $s->{pie_height}, $ac)
			if ( in_front($pa) && $s->{'3d'} );

		# Make an estimate of a point in the middle of the pie slice
		# And fill it
		($xe, $ye) = cartesian(
				3 * $s->{w}/8, ($pa+$pb)/2,
				$s->{xc}, $s->{yc}, $s->{h}/$s->{w}
			);

		$s->{graph}->fillToBorder($xe, $ye, $ac, $dc);

		# If it's 3d, colour the front ones as well
		#
		# if one slice is very large (>180 deg) then we will need to
		# fill it twice.  sbonds.
		#
		# Independently noted and fixed by Jeremy Wadsack, in a slightly
		# different way.
		if ( $s->{'3d'} ) 
		{
			foreach my $fill ($s->_get_pie_front_coords($pa, $pb)) 
			{
				$s->{graph}->fillToBorder(
					$fill->[0], $fill->[1] + $s->{pie_height}/2, $ac, $dc);
			}
		}
	}

	# CONTRIB Jeremy Wadsack
	#
	# Large text, sticking out over the pie edge, could cause 3D pies to
	# fill improperly: Drawing the text for a given slice before the
	# next slice was drawn and filled could make the slice boundary
	# disappear, causing the fill colour to flow out.  With this
	# implementation, all the text is on top of the pie.

	$pb = $s->{start_angle};
	for $i (0 .. $s->{numpoints} ) 
	{
		next unless $data->[0][$i];

		my $pa = $pb;
		$pb += my $slice_angle = 360 * $data->[1][$i]/$total;

		next if ($slice_angle <= $s->{suppress_angle});

		my ($xe, $ye) = 
			cartesian(
				3 * $s->{w}/8, ($pa+$pb)/2,
				$s->{xc}, $s->{yc}, $s->{h}/$s->{w}
			);

		$s->put_slice_label($xe, $ye, $data->[0][$i]);
	}

} #GD::Graph::pie::draw_data

sub _get_pie_front_coords # (angle 1, angle 2)
{
	my $s = shift;
	my $pa = level_angle(shift);
	my $pb = level_angle(shift);
	my @fills = ();

	if (in_front($pa))
	{
		if (in_front($pb))
		{
			# both in front
			# don't do anything
			# Ah, but if this wraps all the way around the back
			# then both pieces of the front need to be filled.
			# sbonds.
			if ($pa > $pb ) 
			{
				# This takes care of the left bit on the front
				# Since we know exactly where we are, and in which
				# direction this works, we can just get the coordinates
				# for $pa.
				my ($x, $y) = cartesian(
					$s->{w}/2, $pa,
					$s->{xc}, $s->{yc}, $s->{h}/$s->{w}
				);

				# and move one pixel to the left, but only if we don't
				# fall out of the pie!.
				push @fills, [$x - 1, $y]
					if $x - 1 > $s->{xc} - $s->{w}/2;

				# Reset $pa to the right edge of the front arc, to do
				# the right bit on the front.
				$pa = level_angle(-$ANGLE_OFFSET);
			}
		}
		else
		{
			# start in front, end in back
			$pb = $ANGLE_OFFSET;
		}
	}
	else
	{
		if (in_front($pb))
		{
			# start in back, end in front
			$pa = $ANGLE_OFFSET - 180;
		}
		else
		{
			# both in back
			return;
		}
	}

	my ($x, $y) = cartesian(
		$s->{w}/2, ($pa + $pb)/2,
		$s->{xc}, $s->{yc}, $s->{h}/$s->{w}
	);

	push @fills, [$x, $y];

	return @fills;
}

# return true if this angle is on the front of the pie
sub in_front # (angle)
{
	my $a = level_angle( shift );
	( $a > ($ANGLE_OFFSET - 180) && $a < $ANGLE_OFFSET ) ? 1 : 0;
}

# XXX Ugh! I need to fix this. See the GD::Text module for better ways
# of doing this.
# return a value for angle between -180 and 180
sub level_angle # (angle)
{
	my $a = shift;
	return level_angle($a-360) if ( $a > 180 );
	return level_angle($a+360) if ( $a <= -180 );
	return $a;
}

# put the slice label on the pie
sub put_slice_label # (GD:Image)
{
	my $self = shift;
	my ($x, $y, $label) = @_;

	return unless defined $label;

	$self->{gdta_value}->set_text($label);
	$self->{gdta_value}->draw($x, $y);
}

# return x, y coordinates from input
# radius, angle, center x and y and a scaling factor (height/width)
#
# $ANGLE_OFFSET is used to define where 0 is meant to be
sub cartesian
{
	my ($r, $phi, $xi, $yi, $cr) = @_; 

	return (
		$xi + $r * cos(PI * ($phi + $ANGLE_OFFSET)/180), 
		$yi + $cr * $r * sin(PI * ($phi + $ANGLE_OFFSET)/180)
	);
}

1;
