# This Makefile requires GNU make. If you have anything else, it is very
# likely that you won't be able to use this. Two pieces of advice:
# 
# Get GNU make. It's free, and superior to many others
#
# Run the examples by hand, one by one, or do something like
#
# tcsh> foreach s (*.pl)
# foreach> perl -I. -I../lib -Tw $s
# foreach> end
#
# If you use an old version of GD that exports GIF, you will need to
# have ImageMagick installed, or you need to provide another way to
# convert logo.png to logo.gif.

.SILENT:

PERL = perl
#OPTIONS = -I/home/mgjv/perl/GD1.19 -I. -I../blib/lib -Tw
OPTIONS = -I. -I../blib/lib -Tw

EXT := \
	$(shell perl $(OPTIONS) -MGD::Graph \
		-e 'print scalar GD::Graph::export_format')

SAMPLES :=  \
		sample11 sample12 sample13 sample14 sample15 sample16 \
		sample17 sample18 \
		sample21 sample22 sample23 \
		sample31 \
		sample41 sample42\
		sample51 sample52 sample53 sample54 sample55 sample56 \
		sample61 sample62 \
		sample71 \
		sample91 sample92 sample93 sample94

IMAGES := $(SAMPLES:%=%.$(EXT))

all: $(IMAGES)
	echo ""
	echo These samples are both examples and test cases. Therefore
	echo some of them might look slightly unrealistic.

%.$(EXT): %.pl
	$(PERL) $(OPTIONS) $<

# Requires ImageMagick to be installed
logo.gif: logo.png
	convert logo.png logo.gif

clean:
	rm -f $(IMAGES) logo.gif

# Other dependencies

sample14.$(EXT): logo.$(EXT)
sample42.$(EXT): sample42.dat
sample54.$(EXT): sample54.dat
sample56.$(EXT): sample54.dat
sample53.$(EXT): rgb.txt

