#==========================================================================
#			   Copyright (c) 1995-1998 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GD::Graph::mixed.pm
#
# $Id: mixed.pm,v 1.3 1999/12/29 12:14:40 mgjv Exp $
#
#==========================================================================

package GD::Graph::mixed;
 
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

my %Defaults = (
	default_type => 'lines',
	mixed => 1,
);

sub initialise
{
	my $s = shift;

	$s->SUPER::initialise();

	my $key;
	foreach $key (keys %Defaults)
	{
		$s->set( $key => $Defaults{$key} );
	}

	# XXX This is a bit ugly. Maybe need to do this with a loop and
	# UNIVERSAL->can..
	$s->GD::Graph::lines::initialise();
	$s->GD::Graph::points::initialise();
	$s->GD::Graph::bars::initialise();
}

sub draw_data_set # GD::Image, \@data, $ds
{
	my $s = shift;
	my $d = shift;
	my $ds = shift;

	my $type = $s->{types}->[$ds-1] || $s->{default_type};

	# Try to execute the draw_data_set function in the package
	# specified by type
	eval '$s->GD::Graph::'.$type.'::draw_data_set($d, $ds)';

	# If we fail, we try it in the package specified by the
	# default_type, and warn the user
	if ($@)
	{
		warn "Set $ds, unknown type $type, assuming $s->{default_type}\n";

		eval '$s->GD::Graph::'.
			$s->{default_type}.'::draw_data_set($d, $ds)';
	}

	# If even that fails, we bail out
	croak "Set $ds: unknown default type $s->{default_type}\n" if $@;
}

sub draw_legend_marker # (GD::Image, data_set_number, x, y)
{
	my $s = shift;
	my $ds = shift;
	my $x = shift;
	my $y = shift;

	my $type = $s->{types}->[$ds-1] || $s->{default_type};

	eval '$s->GD::Graph::'.$type.'::draw_legend_marker($ds, $x, $y)';

	eval '$s->GD::Graph::'.
		$s->{default_type}.'::draw_legend_marker($ds, $x, $y)' if $@;
}

1;
