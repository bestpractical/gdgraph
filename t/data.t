use Test;
use strict;

BEGIN { plan tests => 26 }

use GD::Graph::Data;
ok(1);
use Data::Dumper;
ok(1);

my @data = (
	[qw( Jan Feb Mar )],
	[11, 12],
	[21],
	[31, 32, 33, 34],
);

# Test setting up of object
my $data = GD::Graph::Data->new();
ok($data);
ok($data->isa("GD::Graph::Data"));

$GD::Graph::Error::Debug = 4;

# Test that empty object is empty
my @l = $data->get_min_max_x;
ok(@l, 0);

my $err_ar_ref = $data->clear_errors;
ok(@{$err_ar_ref}, 1);

# Fill with the data above
my $rc = $data->copy_from(\@data);
ok($rc);

#@l = $data->get_min_max_x;
#ok(@l, 2);
#ok("@l", "Jan Jan"); # Nonsensical test for non-numeric data

@l = $data->get_min_max_y(1);
ok(@l, 2);
ok("@l", "11 12");

my $nd = $data->num_sets;
ok($nd, 3);

@l = $data->get_min_max_y($nd);
ok(@l, 2);
ok("@l", "31 34");

my $np = $data->num_points;
my $y = $data->get_y($nd, $np-1);
ok($np, 3);
ok($y, 33);

$data->add_point(qw(X3 13 23 35));
$nd = $data->num_sets;
$np = $data->num_points;
$y = $data->get_y($nd, $np-1);
ok($nd, 3);
ok($np, 4);
ok($y, 35);

@l = $data->y_values(3) ;
ok(@l, 4);
ok("@l", "31 32 33 35");

$data->cumulate(preserve_undef => 0) ;
@l = $data->y_values(3);
ok(@l, 4);
ok("@l", "63 44 33 71");

$data->reverse;
@l = $data->y_values(1) ;
ok(@l, 4);
ok("@l", "63 44 33 71");

@l = $data->get_min_max_y_all;
ok(@l, 2);
ok("@l", "0 71");

my $data2 = $data->copy;
ok($data2);
ok($data2->isa("GD::Graph::Data"));
ok(Dumper($data2), Dumper($data));

__END__
# TODO
# tests for data file reading

$data->read(file => '/tmp/foo.dat', delimiter => qr/\s+/) or 
        die $data->error;
die $data->error if $data->error;

# Should compare $data2 to $data with Data::Dumper.
