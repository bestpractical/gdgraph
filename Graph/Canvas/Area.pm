#==========================================================================
#			   Copyright (c) 2000 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GD::Graph::Canvas::Area.pm
#
# $Id: Area.pm,v 1.1 2000/05/01 13:51:24 mgjv Exp $
#
#==========================================================================

=head1 NAME

GD::Graph::Canvas::Area - Canvas Area

=head1 SYNOPSIS

  use GD::Graph::Canvas::Area;

=head1 DESCRIPTION

=cut

package GD::Graph::Canvas::Area;

$GD::Graph::Canvas::Area::VERSION = '$Revision: 1.1 $' =~ /\s([\d.]+)/;

use strict;
#use GD::Graph::Canvas::Layer;

sub new
{
	my $proto = shift;
	my $class = ref($proto) || $proto;
	my $self = { @_ };
	bless $self => $class;
	return $self;
}

sub add_area
{
    my $self = shift;
    my $area = shift || return;
    push @{$self->{_areas}}, $area;
}

sub add_layer
{
    my $self = shift;
    my $layer = shift || return;
    push @{$self->{_layers}}, $layer;
}

=head1 AUTHOR

Martien Verbruggen E<lt>mgjv@comdyn.com.auE<gt>

=head2 Copyright

Copyright (c) 2000 Martien Verbruggen.

All rights reserved. This package is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<GD::Graph>, L<GD::Graph::Canvas>, L<GD::Graph::Canvas::Layer>

=cut

"Just another true value";
