#==========================================================================
#              Copyright (c) 1995-1998 Martien Verbruggen
#--------------------------------------------------------------------------
#
#   Name:
#       GD::Graph::hbars.pm
#
# $Id: hbars.pm,v 1.1 2002/06/08 13:35:05 mgjv Exp $
#
#==========================================================================
 
package GD::Graph::hbars;

$GD::Graph::hbars::VERSION = '$Revision: 1.1 $' =~ /\s([\d.]+)/;

use strict;

# TODO: I should be able to inherit from axestype. Problems with bars
# when x0 != 0

use GD::Graph::bars;
use GD::Graph::utils qw(:all);
use GD::Graph::colour qw(:colours);

@GD::Graph::hbars::ISA = qw(GD::Graph::bars);

use constant PI => 4 * atan2(1,1);

sub initialise
{
    my $self = shift;
    $self->SUPER::initialise();
    $self->set(rotate_chart => 1);
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

        my $l = $self->_get_bottom($ds, $i);
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

        # get coordinates of right and center of bar
        my ($r, $xp) = $self->val_to_pixel($i + 1, $value, $ds);

        # calculate top and bottom of bar
        my ($t, $b);

        if (ref $self eq 'GD::Graph::mixed' || $self->{overwrite})
        {
            $t = $xp - $self->{x_step}/2 + $bar_s + 1;
            $b = $xp + $self->{x_step}/2 - $bar_s;
        }
        else
        {
            $t = $xp 
                - $self->{x_step}/2
                + ($ds - 1) * $self->{x_step}/$self->{_data}->num_sets
                + $bar_s + 1;
            $b = $xp 
                - $self->{x_step}/2
                + $ds * $self->{x_step}/$self->{_data}->num_sets
                - $bar_s;
        }

        # draw the bar
        if ($value >= 0)
        {
            # positive value
            $self->{graph}->filledRectangle(
                $l, $t + $bsd, $r - $bsd, $b + $bsd, $bsci
            ) if $bsd;
            $self->{graph}->filledRectangle($l, $t, $r, $b, $dsci)
                if defined $dsci;
            $self->{graph}->rectangle($l, $t, $r, $b, $brci) 
                if defined $brci && $b - $t > $self->{accent_treshold};

            $self->{_hotspots}->[$ds]->[$i] = ['rect', $t, $l, $r, $b]
        }
        else
        {
            # negative value
            $self->{graph}->filledRectangle(
                $l + $bsd, $t, $r + $bsd, $b, $bsci
            ) if $bsd;
            $self->{graph}->filledRectangle($r, $t, $l, $b, $dsci)
                if defined $dsci;
            $self->{graph}->rectangle($l, $t, $r, $b, $brci) 
                if defined $brci && $b - $t > $self->{accent_treshold};

            $self->{_hotspots}->[$ds]->[$i] = ['rect', $t, $l, $b, $r]
        }
    }

    return $ds;
}


"Just another true value";

__END__

=head1 NAME

GD::Graph::hbars - make bar graphs with horizontal bars

=head1 SYNPOSIS

use GD::Graph::hbars;

my $graph = GD::Graph::hbars->new();

$graph->set( ... );


=head1 DESCRIPTION

I duplicated quite a bit of code in this module
by overriding methods from axestype.pm and bars.pm.  The
original versions of these functions assumed that the 
X-axis was along a horizontal line reading from left to
right, and the y-axis was along a vertical line reading
from bottom to top.  I could not change this without
completely replacing the functions.  This is not a 
good, permanant solution.

This module inherits from GD::Graph::bars, which allows
GD::Graph::axestype to recognize it as a bar-graph with
a miminal change to GD::Graph::axestype.  This requires
a change to axestype.pm though:

    --- /usr/local/src/cpan/build/GDGraph-1.33/Graph/axestype.pm    Sat Oct  7 00:52:41 2000
    +++ /usr/local/lib/perl5/site_perl/GD/Graph/axestype.pm Mon Jun  3 22:22:48 2002
    @@ -1050,9 +1050,8 @@
     
            # Make sure bars and area always have a zero offset
            # This has to work for all subclasses
    -       my ($subclass) = ref($self) =~ m/.*::(.*)$/;
     
    -       if (defined $subclass and ($subclass eq 'bars' or $subclass eq 'area'))
    +       if ( $self->isa('GD::Graph::bars') or $self->isa('GD::Graph::area') )
            {
                    for my $i (1..($self->{two_axes} ? 2 : 1))
                    {

=head1 SEE ALSO

L<GD::Graph>

=head1 AUTHOR

based on GD::Graph::axestype and GD::Graph::bars by 
Martien Verbruggen.  Minor changes by brian d foy
<bdfoy@cpan.org> to make it work for horizontal bars.

=head1 MAINTENANCE

THIS CODE IS NOT OFFICIALLY SUPPORTED BY GD::Graph

This module is not bundled with GD::Graph, and contains
some fragile code.  If GD::Graph changes, this code may
break.

Seriously consider the lack of official maintenance and
upkeep for this module before you lock in your project 
to its use.  I (brian d foy) will do what I can to fix
problems and respond to bugs, but if GD::Graph changes
significantly or I have other pressing commitments, I
may not be able to provide the quality of care I normally
give to modules under my complete control.

Please consider supporting this locally if you decide to
use it.  I can answer questions about why things are
the way they if you do not understand something.  Please
do not bother the other GD::Graph maintainers if you have
problems with this module.

THIS CODE IS NOT OFFICIALLY SUPPORTED BY GD::Graph

=cut

