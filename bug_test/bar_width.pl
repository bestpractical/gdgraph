#!/usr/bin/perl -w
use strict;

use lib 'blib/lib';

use GD::Graph::bars;
use GD::Graph::Data;
use Image::Magick;
my $im = Image::Magick->new();

my $data = GD::Graph::Data->new();

for (1..20)
{
	$data->add_point($_, rand);
	$data->add_point($_, rand);
	my $g = GD::Graph::bars->new();
	$g->set(correct_width => 0, transparent => 0);
	$g->plot($data);
	$im->BlobToImage($g->gd->png);
}

$im->Display;

