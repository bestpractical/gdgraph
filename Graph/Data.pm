#==========================================================================
#			   Copyright (c) 1995-1998 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GD::Graph::Data.pm
#
# $Id: Data.pm,v 1.1 2000/02/07 13:41:55 mgjv Exp $
#
#==========================================================================

package GD::Graph::Data;

use strict;

=head1 NAME

GD::Graph::Data - Data set encapsulation for GD::Graph

=head1 SYNOPSIS

use GD::Graph::Data;

=head1 DESCRIPTION

This module encapsulates the data structure that is needed for GD::Graph
and friends. An object of this class contains a list of X values, and a
number of lists of corresponding Y values.

=head1 EXAMPLES

  use GD::Graph::Data;
  use GD::Graph::bars;

  my $data = GD::Graph::Data->new();

  XXX MORE

  my $chart = GD::Graph::bars->new();
  my $gd = $chart->plot($data);

=head1 METHODS

=head2 $data = GD::Graph::Data->new()

Create a new GD::Graph::Data object.

=cut

sub new
{
	my $proto = shift;
	my $class = ref($proto) || $proto;
	my $self = [];
	bless $self => $class;
}

=head1 $data->reset

Reset the data container. Get rid of all data.

=cut

sub reset
{
	my $self = shift;
	my $class = ref($self);
	$self = [];
	bless $self => $class;
}

# $data->set_value(nd, np, nvalue)
sub _set_value
{
	my $self = shift;
	my ($nd, $np, $val) = @_;
	return if $nd < 0 && $np < 0;

	# Make sure we have empty arrays in between
	if ($nd > $self->num_sets)
	{
		# XXX do this with splice
		for ($self->num_sets .. $nd - 1)
		{
			push @{$self}, [];
		}
	}
	$self->[$nd][$np] = $val;
}

=head2 $data->set_x($np, $value);

Set the X value of point I<$np> to I<$value>. Points are numbered
starting with 0. You probably will never need this.

Returns I<$np> on success, undef on failure.

=cut

sub set_x
{
	my $self = shift;
	$self->_set_value(0, @_);
}

=head2 $data->set_y($nd, $np, $value);

Set the Y value of point I<$np> of data set I<$nd> to I<$value>. Points
are numbered starting with 0, data sets are numbered starting with 1.
You probably will never need this.

Returns I<np> on success, undef on failure.

=cut

sub set_y
{
	my $self = shift;
	return if $_[0] < 1;
	$self->_set_value(@_);
}

=head1 $data->add_point($X, $Y1, $Y2 ...)

Adds a point to the data set. The number of arguments to this call
should be the same on each call. It is only valid to call this method if
each Y value list has exactly the same length as the X value list at all
times, otherwise results can be quite unpredictable.

Returns undef on failure. 

=cut

sub add_point
{
	my $self = shift;
	return if (@_ != $self->num_sets + 1);
	my $point = $self->num_points;

	for (my $ds = 0; $ds < @_; $ds++)
	{
		$self->_set_value($ds, $point, $_[$ds]);
	}
	return $self->num_points;
}

=head1 $data->num_sets

Returns the number of data sets.

=cut

sub num_sets
{
	my $self = shift;
	return @{$self} - 1;
}

=head1 $data->num_points

Returns a list with its first element the number of X values, and the
subsequent elements the number of respective Y values for each data set.
In scalar context returns the number of X points that have an X value
set.

=cut

sub num_points
{
	my $self = shift;
	wantarray ?
		map { scalar @{$_} } @{$self} :
		scalar @{$self->[0]}
}

=head1 $data->x_values

Return a list of all the X values.

=cut

sub x_values
{
	my $self = shift;
	return @{$self->[0]};
}

=head1 $data->y_values($ds)

Return a list of the Y values for data set I<$ds>. Data sets are
numbered from 1.

=cut

sub y_values
{
	my $self = shift;
	my $ds   = shift;
	return if $ds < 1 || $ds > $self->num_sets;
	return @{$self->[$ds]};
}

=head1 $data->make_strict

Make all data set lists the same length as the X list by truncating data
sets that are too long, and filling data sets that are too short with
undef values.

=cut

sub make_strict
{
	my $self = shift;

	for my $ds (1 .. $self->num_sets)
	{
		my $data_set = $self->[$ds];

		my $short = $self->num_points - @{$data_set};
		next if $short == 0;

		if ($short > 0)
		{
			my @fill = (undef) x $short;
			push @{$data_set}, @fill;
		}
		else
		{
			splice @{$data_set}, $short;
		}
	}
}

=head1 $data->copy_from(\@data)

Copy an 'old' style GD::Graph data structure or another GD::Graph::Data
object into this object.

Returns undef on failure.

=cut

sub copy_from
{
	my $self = shift;
	my $data = shift;
	return unless ref($data) eq 'ARRAY' || 
				  ref($data) eq 'GD::Graph::Data';
	
	$self->reset;

	for my $data_set (@{$data})
	{
		return unless ref($data_set) eq 'ARRAY';
		push @{$self}, [@{$data_set}];
	}

	return $self->num_points;
}

=head1 $data->copy(wanted = $array_ref, strict => boolean)

Returns a copy of the object, or undef on failure.

If B<wanted> is present and a reference to an array, then the elements of
that array will be taken to be the numbers of the data sets you want to
copy. For example, if you want data sets 1, 3 and 6, you'd do

  $new_data = $data->copy(wanted => [1, 3, 6]);

If the B<strict> parameter is present and set to a true value, returns a
copy of the object, but with all the data sets 'levelled' to the
contents of the X values list. This means that it will discard any Y
values that do not have a corresponding X value (see
L<"make_strict">). 

  $new_data = $data->copy(strict => 1);

The B<cumulate> parameter will return a copy with the Y values
summarised. This means that the first Y value list will be unchanged,
but the second will contain a sum of the first and second, the third
will contain the sum of first, second and third, and so on.

  $new_data = $data->copy(cumulate => 1);

=cut

sub copy
{
	my $self = shift;
	my $origin = $self;

	return if (@_ && @_ % 2);
	my %args = @_;

	if ($args{wanted} && ref($args{wanted}) eq 'ARRAY')
	{
		$origin = [];
		push @{$origin}, [$self->x_values];
		my $i = 1;
		for my $w (@{$args{wanted}})
		{
			# XXX Fix this when cop_from is fixed
			push @{$origin}, [$self->y_values($w)];
			#$origin->[$i++] = [$self->y_values($w)];
		}
	}

	my $new = $self->new();
	$new->copy_from($origin);
	$new->make_strict if $args{strict};
	return $new;
}

=head1 NOTES

As with all Modules for Perl: Please stick to using the interface. If
you try to fiddle too much with knowledge of the internals of this
module, you could get burned. I may change them at any time.
Specifically, I probably won't always keep this implemented as an array
reference.

=head1 AUTHOR

Martien Verbruggen <mgjv@comdyn.com.au>

=head2 Copyright

GD::Graph: Copyright (c) 1999 Martien Verbruggen.

All rights reserved. This package is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<GD::Graph>

=cut

"Just another true value"

