#==========================================================================
#			   Copyright (c) 1995-1998 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GD::Graph::Data.pm
#
# $Id: Data.pm,v 1.2 2000/02/08 12:36:05 mgjv Exp $
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
number of lists of corresponding Y values. This only really makes sense
if the Y values are numerical, but you can basically store anything.
Undefined values have a special meaning to GD::Graph, so they are
treated with care when stored.

Many of the methods of this module are intended for internal use by
GD::Graph and the module itself, and will most likely not be useful to
you. Many won't even I<seem> useful to you...

=head1 EXAMPLES

  use GD::Graph::Data;
  use GD::Graph::bars;

  my $data = GD::Graph::Data->new();

  $data->read(file => '/data/sales.dat', delimiter => ',');
  $data = $data->copy(wanted => [2, 4, 5]);

  # Add the newer figures from the database
  use DBI;
  # do DBI things, like connecting to the database, statement
  # preparation and execution

  while (@row = $sth->fetchrow_array)
  {
	  $data->add_point(@row);
  }

  my $chart = GD::Graph::bars->new();
  my $gd = $chart->plot($data);

or for quick changes to legacy code

  # Legacy code builds array like this
  @data = ( [qw(Jan Feb Mar)], [1, 2, 3], [5, 4, 3], [6, 3, 7] );

  # And we quickly need to do some manipulations on that
  my $data = GD::Graph::Data->new();
  $data->copy_from(\@data);

  # And now do all the new stuff that's wanted.

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

sub _set_value
{
	my $self = shift;
	my ($nd, $np, $val) = @_;
	return if $nd < 0 && $np < 0;

	# Make sure we have empty arrays in between
	if ($nd > $self->num_sets)
	{
		# XXX maybe do this with splice
		for ($self->num_sets .. $nd - 1)
		{
			push @{$self}, [];
		}
	}
	$self->[$nd][$np] = $val;

	return 1;
}

=head2 $data->set_x($np, $value);

Set the X value of point I<$np> to I<$value>. Points are numbered
starting with 0. You probably will never need this. Returns undef on
failure.

=cut

sub set_x
{
	my $self = shift;
	$self->_set_value(0, @_);
}

=head2 $data->get_x($np)

Get the X value of point I<$np>. See L<"set_x">.

=cut

sub get_x
{
	my $self = shift;
	my $np   = shift;

	return unless defined $np;

	$self->[0][$np];
}

=head2 $data->set_y($nd, $np, $value);

Set the Y value of point I<$np> in data set I<$nd> to I<$value>. Points
are numbered starting with 0, data sets are numbered starting with 1.
You probably will never need this. Returns undef on failure.

=cut

sub set_y
{
	my $self = shift;
	return if $_[0] < 1;
	$self->_set_value(@_);
}

=head2 $data->get_y($nd, $np)

Get the Y value of point I<$np> in data set I<$nd>. See L<"set_y">.

=cut

sub get_y
{
	my $self = shift;
	my $nd   = shift;
	my $np   = shift;

	return if $nd < 1 || $nd > $self->num_sets;
	return unless defined $np;

	$self->[$nd][$np];
}

=head2 $data->add_point($X, $Y1, $Y2 ...)

Adds a point to the data set. The base for the addition is the current
number of X values. This means that if you have a data set with the
following contents:

  (X1,  X2)
  (Y11, Y12)
  (Y21)
  (Y31, Y32, Y33, Y34)

that a C<$data->add_point(Xx, Y1x, Y2x, Y3x, Y4x)> will result in

  (X1,    X2,    Xx )
  (Y11,   Y12,   Y1x)
  (Y21,   undef, Y2x)
  (Y31,   Y32,   Y3x,  Y34)
  (undef, undef, Y4x)

In other words: beware how you use this. As long as you make sure that
all data sets are of equal length, this method is safe to use.

=cut

sub add_point
{
	my $self = shift;
	#return if (@_ != $self->num_sets + 1);
	my $point = $self->num_points;

	for (my $ds = 0; $ds < @_; $ds++)
	{
		$self->_set_value($ds, $point, $_[$ds]);
	}
	return 1;
}

=head2 $data->num_sets

Returns the number of data sets.

=cut

sub num_sets
{
	my $self = shift;
	@{$self} - 1;
}

=head2 $data->num_points

In list context, returns a list with its first element the number of X
values, and the subsequent elements the number of respective Y values
for each data set. In scalar context returns the number of points
that have an X value set, i.e. the number of data sets that would result
from a call to C<make_strict>.

=cut

sub num_points
{
	my $self = shift;
	return unless @{$self};
	wantarray ?
		map { scalar @{$_} } @{$self} :
		scalar @{$self->[0]}
}

=head2 $data->x_values

Return a list of all the X values.

=cut

sub x_values
{
	my $self = shift;
	@{$self->[0]};
}

=head2 $data->y_values($nd)

Return a list of the Y values for data set I<$nd>. Data sets are
numbered from 1.

=cut

sub y_values
{
	my $self = shift;
	my $nd   = shift;

	return if $nd < 1 || $nd > $self->num_sets;

	@{$self->[$nd]};
}

=head2 $data->reset

Reset the data container. Get rid of all data.

=cut

sub reset
{
	my $self = shift;
	@{$self} = ();
	return 1;
}

=head2 $data->make_strict

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
	return 1;
}

=head2 $data->cumulate

The B<cumulate> parameter will summarise the Y value sets as follows:
that the first Y value list will be unchanged, the second will contain a
sum of the first and second, the third will contain the sum of first,
second and third, and so on.  Returns undef on failure.

Note: Any non-numerical Y values will be treated as 0. But you really
shouldn't be using this to store that sort of Y data. This is mainly for
internal use by GD::Graph, but if you can find a use for it, you're
welcome.

=cut

sub cumulate
{
	my $self = shift;

	# For all the sets, starting at the last one, ending just 
	# before the first
	for (my $ds = $self->num_sets; $ds > 1; $ds--)
	{
		# For each point in the set
		for my $point (0 .. $#{$self->[$ds]})
		{
			# Add the value for each point in lower sets to this one
			for my $i (1 .. $ds - 1)
			{
				# If neither are defined, we want to preserve the
				# undefinedness of this point. If we don't do this, then
				# the mathematical operation will force undef to be a 0.
				next if 
					! defined $self->[$ds][$point] &&
					! defined $self->[$i][$point];

				$self->[$ds][$point] += $self->[$i][$point];
			}
		}
	}
	return 1;
}

=head2 $data->copy_from(\@data)

Copy an 'old' style GD::Graph data structure or another GD::Graph::Data
object into this object. This will remove the current data. Returns undef
on failure.

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

	return 1;
}

=head2 $data->copy(I<arguments>)

Returns a copy of the object, or undef on failure. Possible arguments
are:

B<wanted>. If this is present and a reference to an array, then the
elements of that array will be taken to be the numbers of the data sets
you want to copy. For example, if you want data sets 1, 3 and 6, you'd
do

  $new_data = $data->copy(wanted => [1, 3, 6]);

B<strict>. if this parameter is present and set to a true value, returns
a copy of the object, but with all the data sets 'levelled' to the
contents of the X values list (see L<"make_strict">). 

  $new_data = $data->copy(strict => 1);

B<cumulate>. This parameter will return a copy with the Y values
summarised (see L<"cumulate">).

  $new_data = $data->copy(cumulate => 1);

=cut

sub copy
{
	my $self = shift;

	return if (@_ && @_ % 2);
	my %args = @_;

	my $origin = $self;

	if ($args{wanted} && ref($args{wanted}) eq 'ARRAY')
	{
		$origin = [];
		push @{$origin}, [$self->x_values];
		for my $w (@{$args{wanted}})
		{
			push @{$origin}, [$self->y_values($w)];
		}
	}

	my $new = $self->new();
	$new->copy_from($origin);
	$new->make_strict if $args{strict};
	$new->cumulate if $args{cumulate};
	return $new;
}

=head2 $data->read(I<arguments>)

Read a data set from a file. This will remove the current data. returns
undef on failure. This method uses the standard module 
Text::ParseWords to parse lines. If you don't have this for some odd
reason, don't use this method, or your program will die.

B<Data file format>: The default data file format is tab separated data
(which can be changed with the delimiter argument). Comment lines are
any lines that start with a #. In the following example I have replaced
literal tabs with <tab> for clarity

  # This is a comment, and will be ignored
  Jan<tab>12<tab>24
  Feb<tab>13<tab>37
  # March is missing
  Mar<tab><tab>
  Apr<tab>9<tab>18

Valid arguments are:

I<file>, mandatory. The file name of the file to read from.

  $data->read(file => '/data/foo.dat');

I<no_comment>. Give this a true value if you don't want lines with an
initial # to be skipped.

  $data->read(file => '/data/foo.dat', no_comment => 1);

I<delimiter>. A regular expression that will become the delimiter
instead of a single tab.

  $data->read(file => '/data/foo.dat', delimiter => '\s+');
  $data->read(file => '/data/foo.dat', delimiter => qr/\s+/);

=cut

sub read
{
	my $self = shift;
	local(*DAT);

	return if (@_ && @_ % 2);
	my %args = @_;

	return unless $args{file};

	my $delim = $args{delimiter} || qr/\t/;

	# The following will die if these modules are not present, as
	# documented.
	require Text::ParseWords;
	import  Text::ParseWords;

	$self->reset;

	open(DAT, $args{file}) or return;
	while(<DAT>)
	{
		chomp;
		next if /^#/ && !$args{no_comment};
		my @fields = parse_line($delim, 1, $_);
		next unless @fields;
		print join(':', @fields), "\n";
		$self->add_point(@fields);
	}
	return 1;
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

