#==========================================================================
#			   Copyright (c) 2000 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GD::Graph::Canvas.pm
#
# $Id: Canvas.pm,v 1.2 2000/05/01 13:51:24 mgjv Exp $
#
#==========================================================================

=head1 NAME

GD::Graph::Canvas - Canvas class for use with GD::Graph

=head1 SYNOPSIS

  use GD::Graph::Canvas;
  @ISA = qw(GD::Graph::Canvas);

=head1 DESCRIPTION

This class is what GD::Graph uses to draw on. It is an abstract thing,
with no output of its own. However, it can be used by other classes to
produce real output.

A canvas is built up of layers and areas.

Each area always contains at least one layer, called the background
layer (In the following this layer is not mentioned when it is the
only one present).

  Canvas
    Layer - background
    Layer - drawing layer
      (container area)
        Area - Title
        (container area)
          Area - Y axis label (left)
          Area - Y tick values (left)
          Area - Chart
            Layer - chart background
            Layer - axes
            Layer - ticks
            Layer - data set 1
            Layer - data set 2
            ...
          Area - Y tick values (right)
          Area - Y axis label (right)
        Area - X tick values
        Area - X axis label
        Area - Bottom Legend
      Area - Right Legend
    
Or more graphical:

  -------------------------------------------------
  |                t i t l e                  |   |
  |-------------------------------------------|   |
  | | |                                   | | |   |
  |y|y|                                   |y|y| r |
  | | |                                   | | | i |
  |l|t|                                   |t|l| g |
  |a|i|                                   |i|a| h |
  |b|c|            chart area             |c|b| t |
  |e|k|                                   |k|e|   |
  |l|s|                                   |s|l| l |
  | | |                                   | | | e |
  | | |                                   | | | g |
  | | |                                   | | | e |
  | | |                                   | | | n |
  |--------------- x tick values -------------| d |
  |--------------- x axis label --------------|   |
  |-------------------------------------------|   |
  |                bottom legend              |   |
  -------------------------------------------------

and for the layers:

      ------------ ... --------------------
      ------------ data set 2 -------------
      ------------ data set 1 -------------
      ------------ ticks ------------------
      ------------ axes -------------------
      ------------ chart background -------
  ---------------- drawing ------------------------
  ---------------- background ---------------------

The C<(container)> areas are only there to contain the others that are
organised below them. This allows a purely vertical and horizontal
packing organisation of the various areas, which makes everything
slightly easier to deal with.

A layer's most important attribute is its order in the drawing chain.
Layers are drawn in the order set up above.  When necessary, a Canvas
driver may elect to duplicate a layer to be drawn more than once, but
layers should never be reordered.

Areas are distinct, non-overlapping parts of a layer, and can be drawn
in any order. They do however have a size and position, expressed as the
corners of a rectangle. 

Coordinate systems are abstract, and coordinates always have a value
between 0 and 1, the origin (0,0) being situated in the bottom left
corner (yes, I know that that is inconvenient for many graphics
packages, but coordinate transformation is fundamental to this whole
exercise anyway).  Apart from the global coordinates, each area has its
own coordinates, with the same rules. This allows a drawing routine to
work on either area without having to worry about how large that area is
going to turn out to be.

=cut

package GD::Graph::Canvas;

$GD::Graph::Canvas::VERSION = '$Revision: 1.2 $' =~ /\s([\d.]+)/;

@GD::Graph::Canvas::ISA = qw( GD::Graph::Canvas::Area );

use strict;
use GD::Graph::Canvas::Layer;
use GD::Graph::Canvas::Area;

=head1 METHODS

=head2 $canvas = GD::Graph::Canvas-E<gt>new()

=cut

sub new
{
	my $proto = shift;
	my $class = ref($proto) || $proto;
	my $self = {};
	bless $self => $class;
    $self->_build_layers();
	return $self;
}

sub _build_layers
{
    my $self = shift;
    my ($layer, $sub_layer, $area, $sub_area, $subsub_area);

    $layer = GD::Graph::Canvas::Layer->new(name => 'chart_layer');
    $self->_add_layer($layer);
      $area = GD::Graph::Canvas::Area->new(name => 'container_top', 
                                           orientation => 'vertical');
      $layer->_add_area($area)
        $sub_area = GD::Graph::Canvas::Area->new(name => 'title');
        $area->add_area($sub_area);
        $sub_area = GD::Graph::Canvas::Area->new(name => 'container_chart', 
                                                 orientation => 'horizontal');
        $area->add_area($sub_area);
          $subsub_area = GD::Graph::Canvas::Area->new(name => 'y_axis_left');
          $sub_area->add_area($subsub_area);
          $subsub_area = GD::Graph::Canvas::Area->new(name => 'y_tick_left');
          $sub_area->add_area($subsub_area);
          $subsub_area = GD::Graph::Canvas::Area->new(name => 'chart');
          $sub_area->add_area($subsub_area);
            $sub_layer = GD::Graph::Canvas::Layer->new(name => 'chart_bg');
            $subsub_area->add_layer($sub_layer);
            $sub_layer = GD::Graph::Canvas::Layer->new(name => 'chart_axes');
            $subsub_area->add_layer($sub_layer);
            $sub_layer = GD::Graph::Canvas::Layer->new(name => 'chart_ticks');
            $subsub_area->add_layer($sub_layer);
            # This is where later the data set layers will be added
          $subsub_area = GD::Graph::Canvas::Area->new(name => 'y_tick_right');
          $sub_area->add_area($subsub_area);
          $subsub_area = GD::Graph::Canvas::Area->new(name => 'y_axis_right');
          $sub_area->add_area($subsub_area);
        $sub_area = GD::Graph::Canvas::Area->new(name => 'x_tick');
        $area->add_area($sub_area);
        $sub_area = GD::Graph::Canvas::Area->new(name => 'x_axis');
        $area->add_area($sub_area);
        $sub_area = GD::Graph::Canvas::Area->new(name => 'legend_bottom');
        $area->add_area($sub_area);
      $area = GD::Graph::Canvas::Area->new(name => 'legend_right');
      $layer->_add_area($area)
}

=head1 AUTHOR

Martien Verbruggen E<lt>mgjv@comdyn.com.auE<gt>

=head2 Copyright

Copyright (c) 2000 Martien Verbruggen.

All rights reserved. This package is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<GD::Graph>

=cut

"Just another true value";

