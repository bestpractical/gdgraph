use Test;
use strict;

BEGIN { plan tests => 8 }

use GD::Graph::colour qw(:colours :lists :convert);

ok(1);

my $colour = '#7fef10';

# Convert a colour between hex and rgb list
my @rgb = hex2rgb($colour);
ok("@rgb", "127 239 16");

my $colour2 = rgb2hex(@rgb);
ok($colour, $colour2);

# Get the number of colours currently defined
my $nc = scalar (@_ = colour_list());

# add a colour explicitly
my $rc = add_colour(foo => [12, 13, 14]);
ok($rc, "foo");
@rgb = _rgb('foo');
ok("@rgb", "12 13 14");

# The next should add a colour, since it hasn't been defined yet
@rgb = _rgb('#7f1020');
ok("@rgb", "127 16 32");

# Check that the colour list is exactly 2 larger than before
my $nc2 = scalar (@_ = colour_list());
ok($nc2, $nc + 2);

$nc2 = scalar (@_ = colour_list(13));
ok($nc2, 13);
