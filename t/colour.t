BEGIN { $| = 1; print "1..7\n"; }
END {print "not ok 1\n" unless $loaded;}
use GD::Graph::colour qw(:colours :lists :convert);
$loaded = 1;
print "ok 1\n";

$i = 2;

$colour = '#7fef10';

# Convert a colour between hex and rgb list
@rgb = hex2rgb($colour);
#print "@rgb\n";
print 'not ' unless "@rgb" eq "127 239 16";
printf "ok %d\n", $i++;

$colour2 = rgb2hex(@rgb);
print 'not ' unless  $colour eq $colour2;
printf "ok %d\n", $i++;

# Get the number of colours currently defined
my $ncolours = scalar (@_ = colour_list());

# add a colour explicitly
$rc = add_colour(foo => [12, 13, 14]);
@rgb = _rgb('foo');
print 'not ' unless $rc eq 'foo' and @rgb and "@rgb" eq "12 13 14";
printf "ok %d\n", $i++;

# The next should add a colour, since it hasn't been defined yet
@rgb = _rgb('#7f1020');
print 'not ' unless @rgb and "@rgb" eq "127 16 32";
printf "ok %d\n", $i++;

# Check that the colour list is exactly 2 larger than before
print 'not ' unless $ncolours + 2 == scalar (@_ = colour_list());
printf "ok %d\n", $i++;

my $ncolours = scalar (@_ = colour_list(13));
print 'not ' unless $ncolours == 13;
printf "ok %d\n", $i++;
