use GD::Graph::Data;
use Data::Dumper;

my $data = GD::Graph::Data->new();

my @data = (
	[qw( Jan Feb Mar )],
	[ 1, 2, 3, 4, 5,  9,],
	[1, 3],
);

$data->copy_from(\@data) || warn 'problems copying';

$data->add_point('Apr', 18, 19) || warn "foobie";
$data->set_x(2, "Grub");
$data->set_y(4, 2, 21);

$data->make_strict;

#my @foo = $data->y_values(3) ;
#print scalar @foo, "@foo\n";

$data = $data->copy(strict => 1, wanted => [1, 3]);

my $dd = Data::Dumper->new([$data], ['data']);
$dd->Deepcopy(1);
print $dd->Dumpxs;
