#==========================================================================
#			   Copyright (c) 1995-2000 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GD::Graph::Error.pm
#
# $Id: Error.pm,v 1.1 2000/02/16 12:45:32 mgjv Exp $
#
#==========================================================================

package GD::Graph::Error;

$GD::Graph::Error::VERSION = 
	(q($Revision: 1.1 $) =~ /\s([\d.]+)/ ? $1 : "0.0");

use strict;

my %Errors;
use vars qw( $Debug );


=head1 NAME

GD::Graph::Error - Error handling for GD::Graph classes

=head1 SYNOPSIS

none.

=head1 DESCRIPTION

This class is a parent for all GD::Graph classes, including
GD::Graph::Data, and offers error and warning handling and some
debugging control.

=head1 METHODS

=head2 $object->error() OR Class->error()

Returns a list of all the errors that the current object has
accumulated. In scalar context, returns the last error. If called as a
class method it works at a class level. This is handy when a constructor
fails, for example:

  my $data = GD::Graph::Data->new()    or die GD::Graph::Data->error;
  $data->read(file => '/foo/bar.data') or die $data->error;

or if you really are only interested in the last error:

  $data->read(file => '/foo/bar.data') or die scalar $data->error;

This implementation does not clear the error list, so if you don't die
on errors, you will need to make sure to never ask for anything but the
last error (put this in scalar context).

Errors are more verbose about where the errors originated if the
$GD::Graph::Data::Debug variable is set to a true value, and even more
verbose if this value is larger than 5.

=cut

# Move errors from an object into the class
# This can be useful if something nasty happens in the constructor,
# while instantiating one of these objects, and you need to move these
# errors into the class space before returning. (see
# GD::Graph::Data::new for an example)
sub _move_errors
{
	my $self = shift;
	my $class = __PACKAGE__;
	push @{$Errors{$class}}, @{$Errors{$self}};
	return;
}

# Subclasses call this to set an error.
sub _set_error
{
	my $self = shift;
	return unless @_;

	my %error = (
		messages => "@_",
		caller   => [caller],
	);
	my $lvl = 1;
	while (my @c = caller($lvl))
	{
		$error{whence} = [@c[0..2]];
		$lvl++;
	}
	push @{$Errors{$self}}, \%error;
	return;
}

sub error
{
	my $self = shift;
	return unless exists $Errors{$self};
	my $error = $Errors{$self};

	my @return;

	@return = 
		map { 
			"$_->{messages}" .
			($Debug ? " at $_->{whence}[1] line $_->{whence}[2]" : '') .
			($Debug > 2 ? " => $_->{caller}[0]($_->{caller}[2])" : '') .
			"\n"
		} 
		@$error;

	wantarray && @return > 1 and  
		$return[-1] =~ s/\n/\n\t/ or
		$return[-1] =~ s/\n//;

	return wantarray ? @return : $return[-1];
}

=head2 $object->has_error() OR Class->has_error()

Returns true if the object (or class) has errors pending, false if not.

This allows you to do things like:

  $data->read(file => '/foo/bar.data');
  while (my @foo = $sth->fetchrow_array)
  {
	  $data->add_point(@foo);
  }
  $data->set_x(12, 'Foo');
  die "ACK!:\n", $data->error if $data->has_error;

And in some cases (see L<"copy">) this is indeed the only way to
check for errors.

=cut

sub has_error
{
	my $self = shift;
	exists $Errors{$self};
}

=head2 $object->clear_errors() or Class->clear_errors()

Clears all outstanding errors.

=cut

sub clear_errors
{
	my $self = shift;
	delete $Errors{$self};
}

sub _dump
{
	my $self = shift;
	require Data::Dumper;
	my $dd = Data::Dumper->new([$self], ['me']);
	$dd->Dumpxs;
}

=head1 NOTES

As with all Modules for Perl: Please stick to using the interface. If
you try to fiddle too much with knowledge of the internals of this
module, you could get burned. I may change them at any time.

=head1 AUTHOR

Martien Verbruggen <mgjv@comdyn.com.au>

=head2 Copyright

Copyright (c) 2000 Martien Verbruggen.

All rights reserved. This package is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<GD::Graph>, L<GD::Graph::Data>

=cut

"Just another true value";
