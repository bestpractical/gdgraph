#==========================================================================
#			   Copyright (c) 1995-1998 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GD::Graph::mixed.pm
#
# $Id: mixed.pm,v 1.6 2000/02/16 12:45:32 mgjv Exp $
#
#==========================================================================

package GD::Graph::mixed;
 
$GD::Graph::mixed::VERSION = 
	(q($Revision: 1.6 $) =~ /\s([\d.]+)/ ? $1 : "0.0");

use strict;
 
use GD::Graph::axestype;
use GD::Graph::lines;
use GD::Graph::points;
use GD::Graph::linespoints;
use GD::Graph::bars;
use GD::Graph::area;
use Carp;
 
# Even though multiple inheritance is not really a good idea, I will
# do it here, because I need the functionality of the markers and the
# line types We'll include axestype as the first one, to make sure
# that's where we look first for methods.

@GD::Graph::mixed::ISA = qw( 
	GD::Graph::axestype 
	GD::Graph::lines 
	GD::Graph::points 
);

sub draw_data_set
{
	my $self = shift;
	my $ds   = $_[0];

	my $rc;

	my $type = $self->{types}->[$ds-1] || $self->{default_type};

	# Try to execute the draw_data_set function in the package
	# specified by type
	$rc = eval '$self->GD::Graph::'.$type.'::draw_data_set(@_)';

	# If we fail, we try it in the package specified by the
	# default_type, and warn the user
	if ($@)
	{
		carp "Set $ds, unknown type $type, assuming $self->{default_type}";

		$rc = eval '$self->GD::Graph::'.
			$self->{default_type}.'::draw_data_set(@_)';
	}

	# If even that fails, we bail out
	croak "Set $ds: unknown default type $self->{default_type}" if $@;

	return $rc;
}

sub draw_legend_marker
{
	my $self = shift;
	my $ds = $_[0];

	my $type = $self->{types}->[$ds-1] || $self->{default_type};

	eval '$self->GD::Graph::'.$type.'::draw_legend_marker(@_)';

	eval '$self->GD::Graph::'.
		$self->{default_type}.'::draw_legend_marker(@_)' if $@;
}

"Just another true value";
