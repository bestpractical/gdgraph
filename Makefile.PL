# This -*- perl -*- script makes the Makefile
# $Id: Makefile.PL,v 1.4 2000/01/02 23:00:53 mgjv Exp $
 
#--- Distribution section ---
 
BEGIN { require 5.005 }
 
use ExtUtils::MakeMaker;
use Config;
 
my @clean = qw(*.old *.save tags);
push @clean, map { "*/$_" } @clean;
 
WriteMakefile(
		'VERSION_FROM'		=> 'lib/GD/Graph.pm',	#finds $VERSION
		'DISTNAME'  		=> 'GDGraph',
		'NAME'				=> 'GD::Graph',

		($] >= 5.005 ?
			('ABSTRACT'		=> 'Produces charts with GD',
			 'AUTHOR'		=> 'Martien Verbruggen <mgjv@comdyn.com.au>',
			) : ()
		),

		'PREREQ_PM'			=> { 
			'GD' => '1.18', 
			'GD::Text::Align' => undef,
		},
 
        'dist'    			=> {
			'COMPRESS' 		=> 'gzip -9f',
			'SUFFIX'   		=> 'gz', 
		},
 
        'clean'   => { 'FILES' => join(" ", @clean), },
);

sub MY::postamble 
{
qq(
samples: all
	\@(cd samples && make PERL=$Config{'perl'})
	\@echo Samples have been created in samples directory

tags:
	ptags lib/GD/*.pm lib/GD/Graph/*.pm
)
}

print <<END;

There are no tests for GD::Graph. The best way to test the package is to
run the examples before installing it.
You can run the examples in the samples directory with `make samples` or
by going into that directory, and just running `make`.
If that fails, please read samples/Makefile.
END

