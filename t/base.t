use lib './t';
use strict;
use GD::Graph::points;

# Ideally I'd like to check other functions like changing colors, borders,
# text styles, etc.  Really give ol' GD a workout.  sbonds.

# Thanks go to http://fonts.linuxpower.org/ for leading me to a source
# of freely available TrueType fonts.

# The selection I made (20thcent.ttf) comes from Ray Larabie.  See the
# 20thcent_Read_Me.txt for details about it.

$::WRITE = 0;
require 'ff.pl';

my @data = ( 
	["1st","2nd","3rd","4th","5th","6th","7th", "8th", "9th"],
	[    3,    7,    8,    2,    4,  1.5,    2,     5,     1],
	[    1,    2,    5,    6,    3,  1.5,    1,     3,     4],
);

my @opts = (
	{},
	{
		'x_label' 		=> 'X Label',
		'y_label' 		=> 'Y label',
		'title' 		=> 'A large (800x600) points chart with default markers',
		'y_max_value' 	=> 10,
		'y_tick_number'	=> 5,
		'y_label_skip' 	=> 2,
		'x_ticks'		=> 1,
	},
	{
		'x_label' 		=> 'X Label',
		'y_label' 		=> 'Y label',
		'title' 		=> 'Default size (test that setting pngx and pngy are ignored)',
		'y_max_value' 	=> 10,
		'y_tick_number'	=> 5,
		'y_label_skip' 	=> 2,
		'x_ticks'		=> 1,
	        'pngx'          => 800,
                'pngy'          => 600,
	},
	{
		'x_label' 		=> 'X Label',
		'y_label' 		=> 'Y label',
		'title' 		=> 'Default size (test TrueType)',
		'y_max_value' 	=> 10,
		'y_tick_number'	=> 5,
		'y_label_skip' 	=> 2,
		'x_ticks'		=> 1,
	},
);

print "1..3\n";
($::WARN) && warn "\n";

foreach my $i (1..3)
{
	my $fn = 't/base' . $i . '.png';

	my $checkImage = get_test_data($fn);
	my $opts = $opts[$i];
	my ($g, $set_return);

	if ($i == 1) {
	  $g = new GD::Graph::points( 800,600 );
	  unless($set_return = $g->set( %$opts )) {
	    print STDERR "set returned '$set_return'\n";
	    print "not ok $i\n";
	    next;
	  }
	}
	elsif ($i == 2) {
	  $g = new GD::Graph::points( );
	  # This should fail since we're setting a read-only attribute
	  # 'pngx' (and 'pngy').
	  if ($set_return = $g->set( %$opts )) {
	    print STDERR "set returned '$set_return'\n";
	    print "not ok $i\n";
	    next;
	  }
	  $g->set_title_font(GD::gdTinyFont);
	}	  
	elsif ($i == 3) {
	  $g = new GD::Graph::points( );
	  unless($set_return = $g->set( %$opts )) {
	    print STDERR "set returned '$set_return'\n";
	    print "not ok $i\n";
	    next;
	  }
	  my %Font = (
		      fontname => "20thcent.ttf",
		      size => 10,
		      angle => 0.05,
		     );
	  $g->set_title_TTF(\%Font);
	}	  
	my $Image = $g->plot( \@data );

	print (($checkImage eq $Image ? "ok" : "not ok"). " $i\n");
	($::WARN) && warn (($checkImage eq $Image ? "ok" : "not ok"). " $i\n");

	write_file($fn, $Image) if ($::WRITE);
}

