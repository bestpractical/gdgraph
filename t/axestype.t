# $Id: axestype.t,v 1.1 2003/06/19 06:28:47 mgjv Exp $
#
# Test stuff related to axestype charts
#
use Test;
use strict;

BEGIN { plan tests => 5 }

# Use "mixed" as the generic chart type to test
use GD::Graph::mixed;
ok(1);
my $g;

# Check for division by 0 errors when all data points are 0
$g = GD::Graph::mixed->new();
if (ok(defined $g))
{
    ok($g->isa("GD::Graph::axestype"));
    my $gd = eval { $g->plot([[qw/A B C D E/], [0, 0, 0, 0, 0]]) };
    if (ok(defined $gd))
    {
	ok($gd->isa("GD::Image"));
    }
    else
    {
	skip($@, 0);
    }
}
else
{
    skip("GD::Graph::mixed->new() failed", 0) for 1..3;
}
