use lib './t';
use strict;
use GD::Graph::pie;

$::WRITE = 0;
require 'ff.pl';

my @data = (
       [],
        [ 
	    ["1st","2nd","3rd","4th","5th","6th"],
	    [    1,    2,    5,    6,    3,  1.5],
        ],
        [
	    ["1st","2nd"],
	    [   88,   12],
        ],
);

my @opts = (
	{},
	{
		 'start_angle'	=> 90,
		'title' 		=> 'A pie chart',
		'label'			=> 'Just data',
	},
	{
		'3d'            => 1,
		'title' 		=> 'A 3D pie chart',
		'label'			=> 'Just data',
	},
);

print "1..2\n";
($::WARN) && warn "\n";

foreach my $i (1..2)
{
	my $fn = 't/pie' . $i . '.png';

	my $checkImage = get_test_data($fn);
	my $opts = $opts[$i];
        my $data = $data[$i];
 
	my $g = new GD::Graph::pie( );
	$g->set( %$opts );
	my $Image = $g->plot( $data );

	print (($checkImage eq $Image ? "ok" : "not ok"). " $i\n");
	($::WARN) && warn (($checkImage eq $Image ? "ok" : "not ok"). " $i\n");

	write_file($fn, $Image) if ($::WRITE);
}

