use GD::Graph::Data;
use Data::Dumper;

my $data = GD::Graph::Data->new();

my @data = (
	[qw( X1 X2 )],
	[qw( 11 12 )],
	[qw( 21 )],
	[qw( 31 32 33 34 )],
);

$data->copy_from(\@data); # || warn $data->error;

#$data->add_point(qw(X3 13 23 33 43));
#$data->set_y(-2, -3, "Grub") || warn $data->error;
#$data->set_y(4, 2, 21);

#$data->make_strict;
#$data->cumulate;

#my @foo = $data->y_values(3) ;
#print scalar @foo, "@foo\n";

$data->read(file => '/tmp/foo.dat', delimiter => qr/\s+/) or 
	die $data->error;

#$data->add_point('Foo', 12, 13);

my $dd = Data::Dumper->new([$data], ['data']);
$dd->Deepcopy(1);

print $dd->Dumpxs;


#$data->cumulate;
$data = $data->copy();
$data->wanted(3, 1, 2);
die $data->error if $data->error;

$dd = Data::Dumper->new([$data], ['data']);
$dd->Deepcopy(1);
print $dd->Dumpxs;
