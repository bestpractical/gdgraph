#==========================================================================
#			   Copyright (c) 1995-1998 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GD::Graph::pie.pm
#
# $Id: pie.pm,v 1.1 1999/12/11 02:40:37 mgjv Exp $
#
#==========================================================================

package GD::Graph::pie;

use strict;

use GD::Graph;
use GD::Graph::utils qw(:all);
use GD::Graph::colour qw(:colours :lists);

@GD::Graph::pie::ISA = qw( GD::Graph );

my $ANGLE_OFFSET = 90;

my %Defaults = (
 
	# Set the height of the pie.
	# Because of the dependency of this on runtime information, this
	# is being set in GD::Graph::pie::initialise
 
	#   pie_height => _round(0.1*${'pngx'}),
 
	# Do you want a 3D pie?
 
	'3d'         => 1,
 
	# The angle at which to start the first data set
	# 0 is at the front/bottom
 
	start_angle => 0,

);

{
	# PUBLIC methods, documented in pod
	sub plot($) # (\@data)
	{
		my $self = shift;
		my $data = shift;

		$self->check_data($data);
		$self->setup_coords();
		$self->init_graph($self->{graph});
		$self->draw_text($self->{graph});
		$self->draw_pie($self->{graph});
		$self->draw_data($data, $self->{graph});

		return $self->{graph}->png;
	}
 
	sub set_label_font($) # (fontname)
	{
		my $self = shift;

		$self->{lf} = shift;
		$self->set( 
			lfw => $self->{lf}->width,
			lfh => $self->{lf}->height,
		);
	}
 
	sub set_value_font($) # (fontname)
	{
		my $self = shift;

		$self->{vf} = shift;
		$self->set( 
			vfw => $self->{vf}->width,
			vfh => $self->{vf}->height,
		);
	}

        sub debug($) {
	    my $self = shift;
	    $self->{_debug} = shift || 1;
	}
 
	# Inherit defaults() from GD::Graph
 
	# PRIVATE
	# called on construction by new.
	sub initialise()
	{
		my $self = shift;
 
		$self->SUPER::initialise();
 
		my $key;
		foreach $key (keys %Defaults) 
		{
			$self->set( $key => $Defaults{$key} );
		}
 
		$self->{_debug} = 0;
		$self->set( pie_height => _round(0.1 * $self->{height}) );
 
		$self->set_value_font(GD::gdTinyFont);
		$self->set_label_font(GD::gdSmallFont);
	}

	# inherit checkdata from GD::Graph
 
	# Setup the coordinate system and colours, calculate the
	# relative axis coordinates in respect to the png size.
 
	sub setup_coords()
	{
		my $s = shift;
 
		# Make sure we're not reserving space we don't need.
		$s->set(tfh => 0) 			unless ( $s->{title} );
		$s->set(lfh => 0) 			unless ( $s->{label} );
		$s->set('3d' => 0) 			if     ( $s->{pie_height} <= 0 );
		$s->set(pie_height => 0)	unless ( $s->{'3d'} );
 
		# Calculate the bounding box for the pie, and
		# some width, height, and centre parameters
		$s->{bottom} = 
			$s->{height} - $s->{pie_height} - $s->{b_margin} -
			( $s->{lfh} ? $s->{lfh} + $s->{text_space} : 0 );

		$s->{top} = 
			$s->{t_margin} + ( $s->{tfh} ? $s->{tfh} + $s->{text_space} : 0 );

		$s->{left} = $s->{l_margin};

		$s->{right} = $s->{width} - $s->{r_margin};

		( $s->{w}, $s->{h} ) = 
			( $s->{right}-$s->{left}, $s->{bottom}-$s->{top} );

		( $s->{xc}, $s->{yc} ) = 
			( ($s->{right}+$s->{left})/2, ($s->{bottom}+$s->{top})/2 );
 
		die "Vertical Png size too small" 
			if ( ($s->{bottom} - $s->{top}) <= 0 );
		die "Horizontal Png size too small"
			if ( ($s->{right} - $s->{left}) <= 0 );

		# set up the data colour list if it doesn't exist yet.
		$s->set( 
			dclrs => [qw( lred lgreen lblue lyellow lpurple cyan lorange )] 
		) unless ( exists $s->{dclrs} );
	}
 
	# inherit open_graph from GD::Graph
 
	# Put the text on the canvas.
	sub draw_text($) # (GD::Image)
	{
		my $s = shift;
		my $g = shift;
 
		if ( $s->{tfh} ) 
		{
			my $tx = $s->{xc} - length($s->{title}) * $s->{tfw}/2;
			$g->string($s->{tf}, $tx, $s->{t_margin}, $s->{title}, $s->{tci});
		}

		if ( $s->{lfh} ) 
		{
			my $tx = $s->{xc} - length($s->{label}) * $s->{lfw}/2;
			my $ty = $s->{height} - $s->{b_margin} - $s->{lfh};
			$g->string($s->{lf}, $tx, $ty, $s->{label}, $s->{lci});
		}
	}
 
	# draw the pie, without the data slices
 
	sub draw_pie($) # (GD::Image)
	{
		my $s = shift;
		my $g = shift;

		my $left = $s->{xc} - $s->{w}/2;

		$g->arc(
			$s->{xc}, $s->{yc}, 
			$s->{w}, $s->{h},
			0, 360, $s->{acci}
		);

		$g->arc(
			$s->{xc}, $s->{yc} + $s->{pie_height}, 
			$s->{w}, $s->{h},
			0, 180, $s->{acci}
		) if ( $s->{'3d'} );

		$g->line(
			$left, $s->{yc},
			$left, $s->{yc} + $s->{pie_height}, 
			$s->{acci}
		);

		$g->line(
			$left + $s->{w}, $s->{yc},
			$left + $s->{w}, $s->{yc} + $s->{pie_height}, 
			$s->{acci}
		);
	}
 
	# Draw the data slices
 
	sub draw_data($$) # (\@data, GD::Image)
	{
		my $s = shift;
		my $data = shift;
		my $g = shift;

		my $total = 0;
		my $j = 1; 						# for now, only one pie..
 
		my $i;
		for $i ( 0 .. $s->{numpoints} ) 
		{ 
			$total += $data->[$j][$i]; 
		}
		die "no Total" unless $total;
 
		my $ac = $s->{acci};			# Accent colour
		my $pb = $s->{start_angle};

		my $val = 0;

		for $i ( 0..$s->{numpoints} ) 
		{
			# Set the data colour
			my $dc = $s->set_clr_uniq( $g, $s->pick_data_clr($i) );

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
			$pb += 360 * $data->[1][$i]/$total;

			# Calculate the end points of the lines at the boundaries of
			# the pie slice
			my ($xe, $ye) = 
				cartesian(
					$s->{w}/2, $pa, 
					$s->{xc}, $s->{yc}, $s->{h}/$s->{w}
				);

			$g->line($s->{xc}, $s->{yc}, $xe, $ye, $ac);

			# Draw the lines on the front of the pie
			$g->line($xe, $ye, $xe, $ye + $s->{pie_height}, $ac)
				if ( in_front($pa) && $s->{'3d'} );

			# Make an estimate of a point in the middle of the pie slice
			# And fill it
			($xe, $ye) = 
				cartesian(
					3 * $s->{w}/8, ($pa+$pb)/2,
					$s->{xc}, $s->{yc}, $s->{h}/$s->{w}
				);

			if ( $s->{_debug} ) {
			  print STDERR "Filling from ($xe,$ye) with $dc\n";
			}
			$g->fillToBorder($xe, $ye, $ac, $dc);

			$s->put_label($g, $xe, $ye, $data->[0][$i]);

			# If it's 3d, colour the front ones as well
			# if one slice is very large (>180 deg) then
			# we will need to fill it twice.  sbonds.
			if ( $s->{'3d'} ) 
			{

			  if ( $s->{_debug} ) {
			    print STDERR "Checking whether to fill between $pa and $pb degrees \n";
			  }
				
			  my $fills = $s->_get_pie_front_coords($pa, $pb);

			  my ($xe, $ye);

			  if (defined($fills->[0])) {
			    my $fill_num;
			    foreach  $fill_num (0..$#{ $fills }) {
			      ($xe, $ye) = @{ $fills->[$fill_num] };
			      if ( $s->{_debug} > 4 ) {
				print STDERR "Filling slice $fill_num front from ($xe,$ye) with $dc\n";
			      }
			      $g->fillToBorder($xe, $ye + $s->{pie_height}/2, $ac, $dc);
			    }
			  }
			}
		}
	} #GD::Graph::pie::draw_data

	sub _get_pie_front_coords($$) # (angle 1, angle 2)
	{
		my $s = shift;
		my $unlevelled_pa = shift;
		my $unlevelled_pb = shift;
		my $pa = level_angle($unlevelled_pa);
		my $pb = level_angle($unlevelled_pb);
		my @fills = ();
		my ($x, $y);

		if ($s->{_debug} > 5) {
		  print "Leveling \$pa: $unlevelled_pa --> $pa\n";
		  print "Leveling \$pb: $unlevelled_pb --> $pb\n";
		}

		if (in_front($pa))
		{
		  if ( $s->{_debug} > 4 ) {
		    print STDERR "Angle $pa is in front\n";
		  }

			if (in_front($pb))
			{
			  if ( $s->{_debug} > 4 ) {
			    print STDERR "Angle $pb is also in front\n";
			  }
			  
			  # both in front
			  # don't do anything
			  # Ah, but if this wraps all the way around the back
			  # then both pieces of the front need to be filled.
			  # sbonds.
			  if ($pa > $pb ) {
			    if ( $s->{_debug} > 5 ) {
			      print STDERR "Wraparound filling at r=" . $s->{w}/2 . " " . ($pa+$ANGLE_OFFSET)/2 . " degrees\n";
			    }

			    ($x, $y) = 
			      cartesian(
					$s->{w}/2, ($pa+$ANGLE_OFFSET)/2,
					$s->{xc}, $s->{yc}, $s->{h}/$s->{w}
				       );

			    push @fills, [ $x, $y ];
			    # Reset $pa to the right edge of the front arc.
			    $pa = level_angle(0-$ANGLE_OFFSET);
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
		  if ( $s->{_debug} > 4 ) {
		    print STDERR "Angle $pa is NOT in front\n";
		  }
			if (in_front($pb))
			{
				# start in back, end in front
				$pa = $ANGLE_OFFSET - 180;
			}
			else
			{
			  if ( $s->{_debug} > 4 ) {
			    print STDERR "Angle $pb is NOT in front either\n";
			  }
				# both in back
				return;
			}
		}

		if ( $s->{_debug} > 5 ) {
		  print STDERR "Filling at r=" . $s->{w}/2 . " " . ($pa+$pb)/2 . " degrees\n";
		}

		($x, $y) = 
			cartesian(
				$s->{w}/2, ($pa+$pb)/2,
				$s->{xc}, $s->{yc}, $s->{h}/$s->{w}
			);

		push @fills, [ $x, $y ];

		return \@fills;
	}
 
	# return true if this angle is on the front of the pie

	sub in_front($) # (angle)
	{
		my $a = level_angle( shift );
		( $a > ($ANGLE_OFFSET - 180) && $a < $ANGLE_OFFSET ) ? 1 : 0;
	}
 
	# return a value for angle between -180 and 180
 
	sub level_angle($) # (angle)
	{
		my $a = shift;
		return level_angle($a-360) if ( $a > 180 );
		return level_angle($a+360) if ( $a <= -180 );
		return $a;
	}
 
	# put the label on the pie
 
	sub put_label($) # (GD:Image)
	{
		my $s = shift;
		my $g = shift;

		my ($x, $y, $label) = @_;

		$x -= length($label) * $s->{vfw}/2;
		$y -= $s->{vfw}/2;
		$g->string($s->{vf}, $x, $y, $label, $s->{alci});
	}
 
	# return x, y coordinates from input
	# radius, angle, center x and y and a scaling factor (height/width)
	#
	# $ANGLE_OFFSET is used to define where 0 is meant to be
	sub cartesian($$$$$) 
	{
		my ($r, $phi, $xi, $yi, $cr) = @_; 
		my $PI=4*atan2(1, 1);

		return (
			$xi + $r * cos($PI * ($phi + $ANGLE_OFFSET)/180), 
			$yi + $cr * $r * sin($PI * ($phi + $ANGLE_OFFSET)/180)
		);
	}
 
	sub pick_data_clr($) # (number)
	{
		my $s = shift;
		return _rgb( $s->{dclrs}[ $_[0] % (1 + $#{$s->{dclrs}}) ] );
	}

} # End of package GD::Graph::pie
 
1;
