#!/usr/local/bin/perl -w
use strict;
use CGI qw/:standard *table/;

# Create an index file for all the samples.

my $EXT = shift || "png";

my %titles = (
    sample1 => 'Bar charts',
    sample2 => 'Area charts',
    sample3 => 'Points charts',
    sample4 => 'Lines and Points charts',
    sample5 => 'Lines charts',
    sample6 => 'Mixed charts',
    sample7 => 'Miscellaneous things',
    sample9 => 'Pie charts',
);

my %links;

foreach my $sgroup (sort keys %titles)
{
    open HTML, ">$sgroup.html" or die $!;

    print HTML start_html($titles{$sgroup}),
		h1($titles{$sgroup}), start_table();

    foreach my $num (1..9)
    {
	foreach my $img ("$sgroup$num.$EXT", "$sgroup$num-h.$EXT")
	{
	    if (-f $img)
	    {
		print HTML Tr(
		    td(a({href => "$sgroup$num.pl"},"$sgroup$num.pl")),
		    td(img({src => "$img", border => 0}))
		    );
	    }
	}
    }

    print HTML end_table(), end_html();
}

open(HTML, ">index.html") or die $!;
print HTML start_html('GD::Graph examples'),
    h1('GD::Graph examples');
foreach my $sgroup (sort keys %titles)
{
    print HTML p(a({href => "$sgroup.html"}, $titles{$sgroup}) );
}
print HTML end_html();

