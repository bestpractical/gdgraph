#==========================================================================
#			   Copyright (c) 2000 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GD::Graph::Canvas::Layer.pm
#
# $Id: Layer.pm,v 1.2 2000/10/07 05:52:41 mgjv Exp $
#
#==========================================================================

=head1 NAME

GD::Graph::Canvas::Layer - Canvas Layer

=head1 SYNOPSIS

  use GD::Graph::Canvas::Layer;

=head1 DESCRIPTION

=cut

package GD::Graph::Canvas::Layer;

$GD::Graph::Canvas::Layer::VERSION = '$Revision: 1.2 $' =~ /\s([\d.]+)/;

use strict;
#use GD::Graph::Canvas::Area;

sub new
{
	my $proto = shift;
	my $class = ref($proto) || $proto;
    my $name = shift;
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

=head1 AUTHOR

Martien Verbruggen E<lt>mgjv@tradingpost.com.auE<gt>

=head2 Copyright

Copyright (c) 2000 Martien Verbruggen.

All rights reserved. This package is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<GD::Graph>, L<GD::Graph::Canvas>, L<GD::Graph::Canvas::Area>

=cut

"Just another true value";
