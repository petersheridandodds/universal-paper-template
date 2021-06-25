#!/usr/bin/perl
# 
# 2021/05/21, psdodds
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

# 
$usage = "make-local-bibfile.pl fooster.bib foo1.tex [foo2.tex] ...  \n" ;

# change next line if necessary
$bibfile = "$ENV{HOME}/papers/biblio/everything.bib";


$outfile = @ARGV[0];

if ($outfile !~ m/\.bib$/) {
    print "Oops: $outfile is not a .bib file ...
Exploding.
";
    exit;
}

@files = @ARGV[1..$#ARGV];

## make a hash for bib entries
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


foreach $file (@files) {

    open (FILE,"$file") or die "can't open $file: $!\n";
    $tex = <FILE>;
    close FILE;

    while ($tex =~ /\\cite\{(.*?)\}/msg) {
	$keylist = $1;
	$keylist =~ s/\s+//g;
	@keys = split(',',$keylist);
	foreach $key (@keys) {
	    # repetition just writes over
	    $localbibhash{$key} = $bibhash{$key};
#	    print $bibhash{$key};
	}
	
    }
    

}

open (OUTFILE,">$outfile") or die "can't open $outfile: $!\n";

foreach $key (keys %localbibhash) {
    print OUTFILE $localbibhash{$key};
}

close OUTFILE;

print "$outfile created.\n";
