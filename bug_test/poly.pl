#! /usr/bin/perl

# Script to clarify problem with poly drawing. See graf1.pl

use GD;

my $gd = GD::Image->new(480, 480);
my $w = $gd->colorAllocate(255, 255, 255);
my $r = $gd->colorAllocate(255,   0,   0);

my $poly = GD::Polygon->new();
while (<DATA>)
{
	chomp;
	my ($x, $y) = split;
	$poly->addPt($x, $y);
}

$gd->filledPolygon($poly, $r);
open(FOO, ">graf2.png") or die $!;
binmode FOO;
print FOO $gd->png;
close FOO;

__DATA__
85	354
150	160
216	276
282	276
348	393
413	160
413	471
348	471
282	471
216	471
150	471
85	471
