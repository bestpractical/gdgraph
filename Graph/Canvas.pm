#==========================================================================
#			   Copyright (c) 2000 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GD::Graph::Canvas.pm
#
# $Id: Canvas.pm,v 1.1 2000/05/01 11:04:33 mgjv Exp $
#
#==========================================================================

package GD::Graph::Canvas;

$GD::Graph::Canvas::VERSION = '$Revision: 1.1 $' =~ /\s([\d.]+)/;

use strict;

=head1 NAME

GD::Graph::Canvas - Abstract Canvas class for use with GD::Graph

=head1 SYNOPSIS

  use GD::Graph::Canvas;
  @ISA = qw(GD::Graph::Canvas);

=head1 DESCRIPTION

=head1 NOTES

As with all Modules for Perl: Please stick to using the interface. If
you try to fiddle too much with knowledge of the internals of this
module, you could get burned. I may change them at any time.
Specifically, I probably won't always keep this implemented as an array
reference.

=head1 AUTHOR

Martien Verbruggen <mgjv@comdyn.com.au>

=head2 Copyright

Copyright (c) 2000 Martien Verbruggen.

All rights reserved. This package is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<GD::Graph>

=cut

"Just another true value";

