#==========================================================================
#			   Copyright (c) 2000 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GD::Graph::Canvas.pm
#
# $Id: Canvas.pm,v 1.4 2000/10/07 05:52:41 mgjv Exp $
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

Areas are distinct, non-overlapping parts of a layer, and can be drawn
in any order. They do however have a size and position, expressed as the
corners of a rectangle. 

Coordinate systems are abstract, and coordinates always have a value
between 0 and 1, the origin (0,0) being situated in the bottom left
corner (yes, I know that that is inconvenient for many graphics
packages, but coordinate transformation is fundamental to this whole
exercise anyway).

=cut

package GD::Graph::Canvas;

$GD::Graph::Canvas::VERSION = '$Revision: 1.4 $' =~ /\s([\d.]+)/;

use strict;

my %__defaults = (
	offset_x 		=>	0,
	offset_y		=> 	0,
	width			=>	10,
	height			=>	7.5,
	units			=>	'cm',
	resolution		=>	72,		# ppi
);

# Sigh. DPI is the standard, so we convert everything to inches
my %__units = 
{
	cm		=>	1/2.5400,		# centimeter
	mm		=>	0.1/2.5400,		# millimeter
	pt		=>	1/72,			# points (US)
	point	=>	1/72,			# points (US)
	pica	=>	1/6,	
	in		=>	1,
	inch	=>	1,
};

=head1 METHODS

=head2 $canvas = GD::Graph::Canvas-E<gt>new()

=cut

sub new
{
	my $proto = shift;
	my $class = ref($proto) || $proto;
	my $self = {%__defaults};
	bless $self => $class;
	return $self;
}

sub units
{
	my $self  = shift;
	my $units = shift;
	if ($units)
	{
		return undef unless exists 	$__units{$units} || 
									$units =~ /^(px|pixel)/;
		$self->{units} = $units;
	}
	$self->{units};
}

sub offset
{
	my $self = shift;
	$self->{offset_x} = shift if @_;
	$self->{offset_y} = shift if @_;
	($self->{offset_x}, $self->{offset_y});
}

sub width
{
	my $self = shift;
	$self->{width} = $_[0] if @_;
	$self->{width};
}

sub height
{
	my $self = shift;
	$self->{height} = $_[0] if @_;
	$self->{height};
}

sub resolution
{
	my $self = shift;
	$self->{resolution} = $_[0] if @_;
	$self->{resolution};
}

sub __to_pixels
{
	my $self = shift;
	my ($x, $y) = @_;
	my ($xp, $yp);
	my $m = exists($__units{$self->{units}) ? 
		$self->{resolution} * $__units{$self->{units} : 1;
	$xp = $m * ($self->{x_offset} + $x * $self->{width});
	$yp = $m * ($self->{y_offset} + $y * $self->{height});
	($xp, $yp);
}

=head1 AUTHOR

Martien Verbruggen E<lt>mgjv@tradingpost.com.auE<gt>

=head2 Copyright

Copyright (c) 2000 Martien Verbruggen.

All rights reserved. This package is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<GD::Graph>

=cut

"Just another true value";

