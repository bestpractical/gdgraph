# This -*- perl -*- script makes the Makefile
# $Id: Makefile.PL,v 1.1.1.1 1999/12/11 02:40:37 mgjv Exp $
 
#--- Distribution section ---
 
BEGIN { require 5.005 }
 
use ExtUtils::MakeMaker;
 
my @clean = qw(*% *.html *.b[ac]k *.old .[A-z]* tags);
push @clean, map { "*/$_" } @clean;
 
WriteMakefile(
		'VERSION_FROM'		=> 'lib/GD/Graph.pm',	#finds $VERSION
	      'DISTNAME'  		=> 'GDGraph',
	      'NAME'      		=> 'GD::Graph',

		($] >= 5.005 ?
			('ABSTRACT'		=> 'Produces charts with GD',
			 'AUTHOR'		=> 'Martien Verbruggen <mgjv@comdyn.com.au>',
			) : ()
		),

		'PREREQ_PM'			=> { 'GD' => "1.18", },
 
        'dist'    			=> {
			'COMPRESS' 		=> 'gzip -9f',
			'SUFFIX'   		=> 'gz', 
		},
 
        'clean'   => { 'FILES' => join(" ", @clean), },
);

