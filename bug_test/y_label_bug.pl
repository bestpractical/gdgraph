#!/usr/local/bin/perl
use GD::Graph::mixed;
my ($customer, %data, $ttf);

$ttf = defined $ARGV[0] ? $ARGV[0] : 'cetus.ttf';

$customer = 'y_label';

%data = (date_ranges=> [ 'Week', 'Month', 'Quarter', 'Year' ],
avg=> ['2.50', '13.00', '17.50', '17.50'],
);

my $g = GD::Graph::mixed->new (350,150);

my @gData= ($data{'date_ranges'},
$data{'avg'});

$g->set(title=> 'New Items to Date',
y_label=> 'Items',
y_label_position=>'1',
transparent=> 0,
types=> [ 'bars', 'linespoints' ],
);

$g->set_y_label_font("$ttf", 12);

open(IMG, ">$customer-graph.png") or die $!;
binmode IMG;
print IMG $g->plot(\@gData)->png;
close IMG;

__END__

Ticket 1737

Subject: Incorrect orientation and position of Y Label if using

First thank you for GD::Graph. It helps me a lot and is fun to work with.

The problem that I have happens when I use a ttf in Basically my y label is rotated
-90 instead of 90 degress from horizontal when I set any ttf for set_y_label_font.

The y label is also not positioned correctly using y_label_position in the vertical
direction. With the value set to 1 to only lies halfway up the axis.

Run this script and look at the resulting output (put cetus.ttf in the working
directory or supply the relative path to a ttf on the command line)
which demonstrates the two issues.

My environment:
SunOS 5.8
perl 5.6.1
GD 2.02
GD::Graph 1.35


