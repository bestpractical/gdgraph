@data = (
    [qw( A )],
    [0,  ],
);

use GD::Graph::bars;
my $c = GD::Graph::bars->new();
$c->plot(\@data);
