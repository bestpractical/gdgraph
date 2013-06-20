#==========================================================================
#              Copyright (c) 1995-1998 Martien Verbruggen
#--------------------------------------------------------------------------
#
#   Name:
#       GD::Graph::pie.pm
#
# $Id: pie.pm,v 1.22 2007/04/27 05:26:47 ben Exp $
#
#==========================================================================

package GD::Graph::pie;

($GD::Graph::pie::VERSION) = '$Revision: 1.22 $' =~ /\s([\d.]+)/;

use strict;

use constant PI => 4 * atan2(1,1);

use GD;
use GD::Graph;
use GD::Graph::utils qw(:all);
use GD::Graph::colour qw(:colours :lists);
use GD::Text::Align;
use Carp;
use POSIX qw(ceil floor);

@GD::Graph::pie::ISA = qw( GD::Graph );

my $ANGLE_OFFSET = 90;

my %Defaults = (
 
    # Set the height of the pie.
    # Because of the dependency of this on runtime information, this
    # is being set in GD::Graph::pie::initialise
 
    #   pie_height => _round(0.1*${'width'}),
    pie_height  => undef,
 
    # Do you want a 3D pie?
    '3d'        => 1,
 
    # The angle at which to start the first data set
    # 0 is at the front/bottom
    start_angle => 0,

    # Angle below which a label on a pie slice is suppressed.
    suppress_angle => 0,    # CONTRIB idea ryan <xomina@bitstream.net>

    # and some public attributes without defaults
    label       => undef,

    # This misnamed attribute is used for pie marker colours
    axislabelclr => 'black',

    aa              => 0,
    alpha           => 0,

    #the percentage for each slice to be displaced from the centre.
    #if this is a reference to an array, each slice is displaced by 
    #the amount in the same array position, or not displaced if there
    #are more slices than offsets.
    #if it is just a number, all slices are exploded this amount
    offsets     => undef,

    # Size of the legend markers
    legend_marker_height    => 8,
    legend_marker_width => 12,
    legend_spacing          => 4,
    legend_placement        => 'BC',        # '[BR][LCR]'
    lg_cols                 => undef,
    legend_frame_margin => 4,
    legend_frame_size       => undef,
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
    $self->set_legend_font(gdTinyFont);
}

# PUBLIC methods, documented in pod
sub plot
{
    my $self = shift;
    my $data = shift;

    $self->check_data($data)        or return;
    $self->init_graph()             or return;
    $self->setup_text()             or return;
    $self->setup_legend();
    $self->setup_coords()           or return;
    $self->draw_text()              or return;
    if ($self->{aa} && $self->{'3d'}){
        $self->draw_pie_data_aa()   or return;
    } else {
        $self->draw_pie()           or return;
        $self->draw_data()          or return;
    }
    $self->draw_legend();

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
    my $self = shift;

    # Make sure we're not reserving space we don't need.
    $self->{'3d'} = 0           if     $self->{pie_height} <= 0;
    $self->set(pie_height => 0) unless $self->{'3d'};

    my $tfh = $self->{title} ? $self->{gdta_title}->get('height') : 0;
    my $lfh = $self->{label} ? $self->{gdta_label}->get('height') : 0;

    # Calculate the bounding box for the pie, and
    # some width, height, and centre parameters (don't forget fenceposts!)
    $self->{bottom} = 
        $self->{height} - $self->{pie_height} - $self->{b_margin} -
        ( $lfh ? $lfh + $self->{text_space} : 0 ) - 1;
    $self->{top} = 
        $self->{t_margin} + ( $tfh ? $tfh + $self->{text_space} : 0 );

    return $self->_set_error('Vertical size too small') 
        if $self->{bottom} - $self->{top} <= 0;

    $self->{left} = $self->{l_margin};
    $self->{right} = $self->{width} - $self->{r_margin} - 1;

    # ensure that the center is a single pixel, not a half-pixel position
    $self->{right}--  if ($self->{right} - $self->{left}) % 2;
    $self->{bottom}-- if ($self->{bottom} - $self->{top}) % 2;

    return $self->_set_error('Horizontal size too small')
        if $self->{right} - $self->{left} <= 0;

    $self->{w} = $self->{right}  - $self->{left} + 1;
    $self->{h} = $self->{bottom} - $self->{top} + 1;

    $self->{xc} = ($self->{right}  + $self->{left})/2; 
    $self->{yc} = ($self->{bottom} + $self->{top})/2;

    #make sure offsets is a reference to an array
    if (exists($self->{offsets}) && !ref($self->{offsets})){
        my @offsets = ();
        for (my $i = 0; $i < $self->{_data}->y_values(1);$i++){
            push (@offsets, $self->{offsets});
        }
        $self->{offsets} = \@offsets;
    }

    if ($self->{aa} && $self->{'3d'}){
        $self->_top_ellipse_size();
        $self->_largest_displacement_ellipse_size();
    }

    return $self;
}

# inherit open_graph from GD::Graph

# Setup the parameters for the text elements
sub setup_text
{
    my $self = shift;

    if ( $self->{title} ) 
    {
        #print "'$s->{title}' at ($s->{xc},$s->{t_margin})\n";
        $self->{gdta_title}->set(colour => $self->{tci});
        $self->{gdta_title}->set_text($self->{title});
    }

    if ( $self->{label} ) 
    {
        $self->{gdta_label}->set(colour => $self->{lci});
        $self->{gdta_label}->set_text($self->{label});
    }

    $self->{gdta_value}->set(colour => $self->{alci});

    $self->{gdta_legend}->set(colour => $self->{legendci});
    $self->{gdta_legend}->set_align('top', 'left');
    $self->{lgfh} = $self->{gdta_legend}->get('height');

    return $self;
}

# Put the text on the canvas.
sub draw_text
{
    my $self = shift;

    $self->{gdta_title}->draw($self->{xc}, $self->{t_margin}) 
        if $self->{title}; 
    $self->{gdta_label}->draw($self->{xc}, $self->{height} - $self->{b_margin})
        if $self->{label};
    
    return $self;
}

# draw the pie, without the data slices
sub draw_pie
{
    my $self = shift;

    my $left = $self->{xc} - $self->{w}/2;

    $self->{graph}->arc(
        $self->{xc}, $self->{yc}, 
        $self->{w}, $self->{h},
        0, 360, $self->{acci}
    );

    $self->{graph}->arc(
        $self->{xc}, $self->{yc} + $self->{pie_height}, 
        $self->{w}, $self->{h},
        0, 180, $self->{acci}
    ) if ( $self->{'3d'} );

    $self->{graph}->line(
        $left, $self->{yc},
        $left, $self->{yc} + $self->{pie_height}, 
        $self->{acci}
    );

    $self->{graph}->line(
        $left + $self->{w}, $self->{yc},
        $left + $self->{w}, $self->{yc} + $self->{pie_height}, 
        $self->{acci}
    );

    return $self;
}

# Draw the data slices

sub draw_data
{
    my $self = shift;

    my $total = 0;
    my @values = $self->{_data}->y_values(1);   # for now, only one pie..
    for (@values)
    {   
        $total += $_ 
    }

    return $self->_set_error("Pie data total is <= 0") 
        unless $total > 0;

    my $ac = $self->{acci};         # Accent colour
    my $pb = $self->{start_angle};

    for (my $i = 0; $i < @values; $i++)
    {
        # Set the data colour
        my $dc = $self->set_clr_uniq($self->pick_data_clr($i + 1));

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
        $pb += my $slice_angle = 360 * $values[$i]/$total;

        # Calculate the end points of the lines at the boundaries of
        # the pie slice
        my ($xe, $ye) = cartesian(
                $self->{w}/2, $pa, 
                $self->{xc}, $self->{yc}, $self->{h}/$self->{w}
            );

        $self->{graph}->line($self->{xc}, $self->{yc}, $xe, $ye, $ac);

        # Draw the lines on the front of the pie
        $self->{graph}->line($xe, $ye, $xe, $ye + $self->{pie_height}, $ac)
            if in_front($pa) && $self->{'3d'};

        # Make an estimate of a point in the middle of the pie slice
        # And fill it
        ($xe, $ye) = cartesian(
                3 * $self->{w}/8, ($pa+$pb)/2,
                $self->{xc}, $self->{yc}, $self->{h}/$self->{w}
            );

        $self->{graph}->fillToBorder($xe, $ye, $ac, $dc);

        # If it's 3d, colour the front ones as well
        #
        # if one slice is very large (>180 deg) then we will need to
        # fill it twice.  sbonds.
        #
        # Independently noted and fixed by Jeremy Wadsack, in a slightly
        # different way.
        if ($self->{'3d'}) 
        {
            foreach my $fill ($self->_get_pie_front_coords($pa, $pb)) 
            {
                my ($fx,$fy) = @$fill;
                my $new_y = $fy + $self->{pie_height}/2;
                # Edge case (literally): if lines have converged, back up 
                # looking for a gap to fill
                while ( $new_y > $fy ) {
                    if ($self->{graph}->getPixel($fx,$new_y) != $ac) {
                        $self->{graph}->fillToBorder($fx, $new_y, $ac, $dc);
                        last;
                    }
                } continue { $new_y-- }
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

    $pb = $self->{start_angle};
    for (my $i = 0; $i < @values; $i++)
    {
        next unless $values[$i];

        my $pa = $pb;
        $pb += my $slice_angle = 360 * $values[$i]/$total;

        next if $slice_angle <= $self->{suppress_angle};

        my ($xe, $ye) = 
            cartesian(
                3 * $self->{w}/8, ($pa+$pb)/2,
                $self->{xc}, $self->{yc}, $self->{h}/$self->{w}
            );

        $self->put_slice_label($xe, $ye, $self->{_data}->get_x($i));
    }

    return $self;

} #GD::Graph::pie::draw_data

sub _get_pie_front_coords # (angle 1, angle 2)
{
    my $self = shift;
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
                    $self->{w}/2, $pa,
                    $self->{xc}, $self->{yc}, $self->{h}/$self->{w}
                );

                # and move one pixel to the left, but only if we don't
                # fall out of the pie!.
                push @fills, [$x - 1, $y]
                    if $x - 1 > $self->{xc} - $self->{w}/2;

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
        elsif ( # both in back, but wrapping around the front
                # CONTRIB kedlubnowski, Dan Rosendorf 
            $pa > 90 && $pb > 90 && $pa >= $pb
            or $pa < -90 && $pb < -90 && $pa >= $pb
            or $pa < -90 && $pb > 90
        ) 
        {   
            $pa=$ANGLE_OFFSET - 180;
            $pb=$ANGLE_OFFSET;
        }
        else
        {
            return;
        }
    }

    my ($x, $y) = cartesian(
        $self->{w}/2, ($pa + $pb)/2,
        $self->{xc}, $self->{yc}, $self->{h}/$self->{w}
    );

    push @fills, [$x, $y];

    return @fills;
}

# return true if this angle is on the front of the pie
# XXX UGLY! We need to leave a slight room for error because of rounding
# problems
sub in_front
{
    my $a = level_angle(shift);
    return 
        $a > ($ANGLE_OFFSET - 180 + 0.00000001) && 
        $a < $ANGLE_OFFSET - 0.000000001;
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
sub put_slice_label
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

    return map _round($_), (
        $xi + $r * cos(PI * ($phi + $ANGLE_OFFSET)/180), 
        $yi + $cr * $r * sin(PI * ($phi + $ANGLE_OFFSET)/180)
    )
}

#functions specific to 3d + aa pies
sub draw_pie_data_aa 
{
    my $self = shift;

    require GD::Graph::pie_slice;

    $self->{pieSlices} = [];

    my $sum = 0;
    my @values = $self->{_data}->y_values(1);   
    for (@values)
    {   
        $sum += $_ 
    }

    return $self->_set_error("Pie data total is <= 0") 
        unless $sum > 0;

    my $largest_displacement = $self->_largest_displacement();

    my @listPieSlices = ();
    my @orderList = ();
    my $clrIndex = 0;
    my $backPieIndex = -1;
    my $displacementIndex = 0;
    my $startAngle = $self->{start_angle};

    for (my $i = 0; $i < @values; $i++){
        my $itemValue = $values[$i];
        #XXX: This isn't right... this round causes things to add up to more than 360
        my $sweepAngle = $itemValue / $sum * 360;
        my $actualSweepAngle = $sweepAngle + $startAngle;

        #get the angle within 360, but keep the decimal places... is there a better way?
        my $startAngleMod = ($startAngle % 360) + ($startAngle - floor($startAngle));
        my $sweepAngleMod = ($actualSweepAngle % 360) + ($actualSweepAngle - floor($actualSweepAngle));
        #print STDERR "startAngle = $startAngle (".$startAngleMod. "), sweepAngle = $sweepAngle, actualSweepAngle = $actualSweepAngle (".$sweepAngleMod .")\n";

        my $xDisplacement = $self->{offsets}[$i];
        my $yDisplacement = $self->{offsets}[$i];
        if ($xDisplacement > 0){
            ($xDisplacement,$yDisplacement) = $self->_get_slice_displacement(($startAngle + $sweepAngle / 2), $xDisplacement);
        }

        if ($actualSweepAngle == 360 && $startAngle == $self->{start_angle}){
            $startAngleMod = 0;
            $sweepAngleMod = 360;
        }

        my @pdc = $self->pick_data_clr($i + 1);
        my $dc = $self->set_clr_uniq(@pdc,$self->{alpha});
        my $shadowClr = $self->set_clr(_darken(@pdc),$self->{alpha});
        my $slice = new GD::Graph::pie_slice(
                             $self->{largestDisplacementEllipseWidth} /2 + $xDisplacement+$self->{left},
                             $self->{largestDisplacementEllipseHeight} /2 + $yDisplacement+$self->{top},
                             $self->{topEllipseWidth},
                             $self->{topEllipseHeight},
                             $self->{pie_height},
                             $startAngleMod,
                             $sweepAngleMod,
                             $self->{_data}->get_x($i),
                             $dc,
                             $shadowClr); 

        #decide when to draw it
        if ($backPieIndex > -1 || (($startAngle <=270) && ($startAngle + $sweepAngle > 270)) || (($startAngle >=270) && ($startAngle + $sweepAngle > 630))){
            $backPieIndex++;
            splice(@listPieSlices,$backPieIndex,0,$slice);
            splice(@orderList,$backPieIndex,0,$i);
        } else {
            push(@listPieSlices,$slice);
            push(@orderList,$i);
        }

        $startAngle += $sweepAngle;
        if ($startAngle > 360){
            $startAngle -= 360;
        }
    }

    $self->{pieSlices} = \@listPieSlices;
    $self->{orderList} = \@orderList;

    #draw the pie!
    foreach my $slice (@listPieSlices){
        $slice->draw_bottom($self->{graph});
    }
    $self->draw_sides(@listPieSlices);
    foreach my $slice (@listPieSlices){
        $slice->draw_top($self->{graph});
    }

    $self->_draw_data();

    return $self;
}#draw_pie_data_aa

#taken from axestype3d.pm
sub _darken 
{
    my( $r, $g, $b ) = @_;
    my $p = ($r + $g + $b) / 70;
    $p = 3 if $p < 3;
    my $f = _max( $r / $p, _max( $g / $p, $b / $p) );
    $r = _max( 0, int( $r - $f ) );
    $g = _max( 0, int( $g - $f ) );
    $b = _max( 0, int( $b - $f ) );
    return( $r, $g, $b );
} # end _darken

sub _largest_displacement
{
    my $self = shift;
    
    my $value = 0;
    foreach my $offset (@{$self->{offsets}}){
        if ($offset > $value){
            $value = $offset;
        }
    }
    return $value;
}

sub _largest_displacement_ellipse_size
{
    my $self = shift;

    my $factor = $self->_largest_displacement();
    $self->{largestDisplacementEllipseWidth} = $self->{topEllipseWidth}*$factor;
    $self->{largestDisplacementEllipseHeight} = $self->{topEllipseHeight}*$factor;

}

sub _top_ellipse_size
{
    my $self = shift;

    my $factor = 1 + $self->_largest_displacement();
    $self->{topEllipseWidth} = $self->{w} / $factor;
    $self->{topEllipseHeight}= $self->{h}/ $factor;
}

sub _get_slice_displacement
{
    my $self = shift;

    my ($angle,$displacementFactor) = @_;
    return (($self->{topEllipseWidth} * $displacementFactor /2 *cos ($angle * PI /180),
            ($self->{topEllipseHeight} * $displacementFactor /2 *sin ($angle * PI /180))));
}

sub draw_sides
{
    my $self = shift;
    my @slices = @_;

    my $inc = 1;
    my $dec = @slices - 1;

    $slices[0]->draw_sides($self->{graph}) ;

    my ($sliceLeft,$sliceRight);
    my ($angle1,$angle2);
    while ($inc < $dec){
        $sliceLeft = $slices[$dec];
        $angle1 = $sliceLeft->{startAngle} - 90;
        if ($angle1 > 180 || $angle1 < 0){
            $angle1 = 0;
        }
        $sliceRight = $slices[$inc];
        $angle2 = 450 - $sliceRight->{startAngle} % 360;
        if ($angle2 > 180 || $angle2 < 0){
            $angle2 = 0;
        }
        if ($angle2 >= $angle1){
            $sliceRight->draw_sides($self->{graph});
            $inc++;
        } elsif ($angle2 < $angle1){
            $sliceLeft->draw_sides($self->{graph});
            $dec--;
        }
    }
    $slices[$dec]->draw_sides($self->{graph});
}

sub get_slices
{
    my $self = shift;
    return $self->{pieSlices};
}

sub get_display_order
{
    my $self = shift;
    my $index = shift;
    return $self->{orderList}[$index];
}

#private function to draw the labels of the slices for 3d-aa pies
sub _draw_data
{
    my $self = shift;
    my @slices = @{$self->{pieSlices}};

    my ($x,$y);
    foreach my $slice (@slices){
        next if ($slice->{sweepAngle} - $slice->{startAngle} < $self->{suppress_angle});

        ($x,$y) = $slice->get_text_position();

        $self->put_slice_label($x, $y, $slice->{label});
    }
}

# Legend Support. Added 16.Feb.2001 - JW/WADG

sub set_legend # List of legend keys
{
    my $self = shift;
    $self->{legend} = [@_];
}

sub set_legend_font # (font name)
{
    my $self = shift;
    $self->_set_font('gdta_legend', @_);
}



#
# Legend
#
sub setup_legend
{
    my $self = shift;

    return unless defined $self->{legend};

    my $maxlen = 0;
    my $num = 0;

    # Save some variables
    $self->{r_margin_abs} = $self->{r_margin};
    $self->{b_margin_abs} = $self->{b_margin};

    foreach my $legend (@{$self->{legend}})
    {
        if (defined($legend) and $legend ne "")
        {
            $self->{gdta_legend}->set_text($legend);
            my $len = $self->{gdta_legend}->get('width');
            $maxlen = ($maxlen > $len) ? $maxlen : $len;
            $num++;
        }
        # Legend for Pie goes over first set, and all points
        last if $num >= $self->{_data}->num_points;
    }

    $self->{lg_num} = $num;

    # calculate the height and width of each element
    my $legend_height = _max($self->{lgfh}, $self->{legend_marker_height});

    $self->{lg_el_width} = 
        $maxlen + $self->{legend_marker_width} + 3 * $self->{legend_spacing};
    $self->{lg_el_height} = $legend_height + 2 * $self->{legend_spacing};

    my ($lg_pos, $lg_align) = split(//, $self->{legend_placement});

    if ($lg_pos eq 'R')
    {
        # Always work in one column
        $self->{lg_cols} = 1;
        $self->{lg_rows} = $num;

        # Just for completeness, might use this in later versions
        $self->{lg_x_size} = $self->{lg_cols} * $self->{lg_el_width};
        $self->{lg_y_size} = $self->{lg_rows} * $self->{lg_el_height};

        # Adjust the right margin for the rest of the graph
        $self->{r_margin} += $self->{lg_x_size};

        # Adjust for frame if defined
        if( $self->{legend_frame_size} ) {
            $self->{r_margin} += 2 * ($self->{legend_frame_margin} + $self->{legend_frame_size});
        } # end if;

        # Set the x starting point
        $self->{lg_xs} = $self->{width} - $self->{r_margin};

        # Set the y starting point, depending on alignment
        if ($lg_align eq 'T')
        {
            $self->{lg_ys} = $self->{t_margin};
        }
        elsif ($lg_align eq 'B')
        {
            $self->{lg_ys} = $self->{height} - $self->{b_margin} - 
                $self->{lg_y_size};
        }
        else # default 'C'
        {
            my $height = $self->{height} - $self->{t_margin} - 
                $self->{b_margin};

            $self->{lg_ys} = 
                int($self->{t_margin} + $height/2 - $self->{lg_y_size}/2) ;
        }
    }
    else # 'B' is the default
    {
        # What width can we use
        my $width = $self->{width} - $self->{l_margin} - $self->{r_margin};

        (!defined($self->{lg_cols})) and 
            $self->{lg_cols} = int($width/$self->{lg_el_width});
        
        $self->{lg_cols} = _min($self->{lg_cols}, $num);

        $self->{lg_rows} = 
            int($num / $self->{lg_cols}) + (($num % $self->{lg_cols}) ? 1 : 0);

        $self->{lg_x_size} = $self->{lg_cols} * $self->{lg_el_width};
        $self->{lg_y_size} = $self->{lg_rows} * $self->{lg_el_height};

        # Adjust the bottom margin for the rest of the graph
        $self->{b_margin} += $self->{lg_y_size};
        # Adjust for frame if defined
        if( $self->{legend_frame_size} ) {
            $self->{b_margin} += 2 * ($self->{legend_frame_margin} + $self->{legend_frame_size});
        } # end if;

        # Set the y starting point
        $self->{lg_ys} = $self->{height} - $self->{b_margin};

        # Set the x starting point, depending on alignment
        if ($lg_align eq 'R')
        {
            $self->{lg_xs} = $self->{width} - $self->{r_margin} - 
                $self->{lg_x_size};
        }
        elsif ($lg_align eq 'L')
        {
            $self->{lg_xs} = $self->{l_margin};
        }
        else # default 'C'
        {
            $self->{lg_xs} =  
                int($self->{l_margin} + $width/2 - $self->{lg_x_size}/2);
        }
    }
}

sub draw_legend
{
    my $self = shift;

    return unless defined $self->{legend};

    my $xl = $self->{lg_xs} + $self->{legend_spacing};
    my $y  = $self->{lg_ys} + $self->{legend_spacing} - 1;

    # If there's a frame, offset by the size and margin
    $xl += $self->{legend_frame_margin} + $self->{legend_frame_size} if $self->{legend_frame_size};
    $y += $self->{legend_frame_margin} + $self->{legend_frame_size} if $self->{legend_frame_size};

    my $i = 0;
    my $row = 1;
    my $x = $xl;    # start position of current element

    foreach my $legend (@{$self->{legend}})
    {
        $i++;
        # Legend for Pie goes over first set, and all points
        last if $i > $self->{_data}->num_points;

        my $xe = $x;    # position within an element

        next unless defined($legend) && $legend ne "";

        $self->draw_legend_marker($i, $xe, $y);

        $xe += $self->{legend_marker_width} + $self->{legend_spacing};
        my $ys = int($y + $self->{lg_el_height}/2 - $self->{lgfh}/2);

        $self->{gdta_legend}->set_text($legend);
        $self->{gdta_legend}->draw($xe, $ys);

        $x += $self->{lg_el_width};

        if (++$row > $self->{lg_cols})
        {
            $row = 1;
            $y += $self->{lg_el_height};
            $x = $xl;
        }
    }
    
    # If there's a frame, draw it now
    if( $self->{legend_frame_size} ) {
        $x = $self->{lg_xs} + $self->{legend_spacing};
        $y = $self->{lg_ys} + $self->{legend_spacing} - 1;
        
        for $i ( 0 .. $self->{legend_frame_size} - 1 ) {
            $self->{graph}->rectangle(
                $x + $i,
                $y + $i, 
                $x + $self->{lg_x_size} + 2 * $self->{legend_frame_margin} - $i - 1,
                $y + $self->{lg_y_size} + 2 * $self->{legend_frame_margin} - $i - 1,
                $self->{acci},
            );
        } # end for
    } # end if
    
}

sub draw_legend_marker # data_set_number, x, y
{
    my $s = shift;
    my $n = shift;
    my $x = shift;
    my $y = shift;

    my $g = $s->{graph};

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

"Just another true value";
