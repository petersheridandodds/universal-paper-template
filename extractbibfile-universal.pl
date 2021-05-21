#!/usr/bin/perl
# 
# december 22, 2015, psdodds
# 
# original:
# june 30, 1999, psdodds
# extractbibfile.pl
# 
# extract bib file that pertains
# exactly to an existing tex document
# (builds on bibfind.pl)
# requires name of tex file and 
# .bbl file must exist

# change next line if necessary
$bibfile = "$ENV{HOME}/papers/biblio/everything.bib";

$file = @ARGV[0];
# remove any .tex suffix
$file =~ s/^(.*)\.tex$/$1/;
# remove any . leftover from tab completion
$file =~ s/^(.*)\.$/$1/;

$bblfile = "$file.bbl";
$outfile = "$file-exact.bib";

open (BBLFILE,"$bblfile") or die "can't open $bblfile: $!\n";
open (OUTFILE,">$outfile") or die "can't open $outfile: $!\n";

## make a hash
## only take first version
open(BIBFILE, "$bibfile") or die "Can't open $bibdir$bibfile.bib: $!\n";

undef $/;
$bibfiles = <BIBFILE>;
@bibentries = split(/^@/m, $bibfiles);

foreach $bibentry (@bibentries) {
 #   print $bibentry;
    $bibentry =~ m/^.*\{(.*?),/;
    $bibref = $1;
#    print "$bibref\n\n";
    if ($bibhash{$bibref} eq "") {
	$bibhash{$bibref} = "@".$bibentry;
    }
#    print $bibhash{$bibref};
}
close BIBFILE;

## print keys %bibhash;

$/ = "\n";

while ($line = <BBLFILE>) {
    if ($line =~ m/^\\bibitem.*\{(.*?)\}/) {
	$name = $1;
	print "$name\n";
#	print $bibhash{$name};
	print OUTFILE $bibhash{$name};
    }
}

print "$outfile created.\n";

close BBLFILE;
close OUTFILE;
