use GD::Graph::bars;
require 'save.pl';

# CONTRIB Edwin Hildebrand.
#
# See changes in bars.pm: Check for bar height rounding errors when 
# stacking bars.

print STDERR "Processing sample 1-8\n";

@dat = qw(
	991006 991007 991114 991117 991118 991119 991120 
	991121 991122 991123 991124 991125 991126 991127 
	991128 991129 991130 991201 991204 991205 991206 
	991207 991208
);

@sub = qw(0 0 0 0 0 0 0 0 1 1 1 1 2 3 1 1 1 1 2 2 6 8 8);
@def = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0);
@rej = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0);
@opn = qw(4 4 4 5 4 4 4 4 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3);
@ass = qw(0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0);
@wrk = qw(1 2 2 2 2 2 1 1 2 2 2 1 1 1 1 1 1 1 1 1 3 6 5);
@fin = qw(0 0 0 0 0 0 1 0 0 0 0 1 1 1 2 2 2 2 2 2 2 2 2);
@ver = qw(0 0 0 0 0 1 1 2 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1);
@con = qw(0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0);
@tst = qw(0 0 0 0 0 0 0 0 1 2 1 1 1 1 1 1 1 1 1 1 1 1 1);
@rev = qw(0 0 0 0 0 0 0 0 1 1 2 1 1 1 1 1 1 1 1 1 1 1 1);
@cco = qw(0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 1 1 0 0 0 0 0 0);
@cls = qw(0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 1 1 1 0 0 0 0);
@sld = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 2 2 3 3 3 4);

# setup x data
push(@data,\@dat);         # push x labels into plot data
push(@data,\@sub);
push(@data,\@def);
push(@data,\@rej);
push(@data,\@opn);
push(@data,\@ass);         # push x values into plot data
push(@data,\@wrk);         # (push order must match legend label order)
push(@data,\@fin);
push(@data,\@ver);
push(@data,\@con);
push(@data,\@tst);
push(@data,\@rev);
push(@data,\@cco);
push(@data,\@cls);
push(@data,\@sld);

# setup legend labels
@legend = qw(
	Submitted Deferred Rejected Opened Assigned Work
	Finished Verified Configured Tested Reviewed
	Closed-CO Closed Sealed
);

# get graph object
$graph = GD::Graph::bars->new(600, 400);

# set graph legend
$graph->set_legend(@legend);

# set graph options
$graph->set(
   'dclrs'            => [ qw(lblue lyellow blue yellow lgreen lred
						      green red purple orange pink dyellow) ],
   'title'            => "States by Time",
   'x_label'          => "Time",
   'y_label'          => "# OF thingies",
   'long_ticks'       => 1,
   'tick_length'      => 0,
   'x_ticks'          => 0,
   'x_label_position' => '.5',     # centered x label
   'y_label_position' => '.5',     # centered y label
   'cumulate'         => 1,        # stacked x data

   'bgclr'            => 'white',  # makes background transparent
   'transparent'      => 0,
   'interlaced'       => 1,        # show like venetian blind opens

								   # number of ticks on y axis
   'y_tick_number'    => 5,
   'y_number_format'  => '%d',     # integer y tick values
								   # min & max adjusted to make tick
   'y_max_value'      => 25,
   'y_min_value'      => 0,

   'y_plot_values'    => 1,        # display tick values
   'x_plot_values'    => 1,        # display tick values
   'x_labels_vertical'=> 1,        # display tick values vertically
   'zero_axis'        => 1,        # show line at y value =0
);

$graph->plot(\@data);
save_chart($graph, 'sample18');

