#!/usr/bin/perl -w
use strict;
use GD::Graph::pie;
use GD::Graph::Data;


my $data = GD::Graph::Data->new();
$data->read(file => 'pie.dat') or die $data->error;

#for (my $angle = 0; $angle < 360; $angle += 30)
#{
	my $angle = 270;
	my $chart = GD::Graph::pie->new(200, 200);
	print "$angle\n";
	$chart->set(start_angle => $angle);
	my $gd = $chart->plot($data) or die $chart->error;
	open(FOO, ">/tmp/foo.png");
	print FOO $gd->png;

#}

