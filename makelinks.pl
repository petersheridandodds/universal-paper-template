#!/usr/bin/perl
# make links into package directory
$usage = "
usage: makelinks.pl foo-combined.tex
(works for any latex file)

use after make-single-latex-file.pl

copies foo-combined.tex to ./package
and replaces figure names by fig001, fig002, etc.

see end of file for localized pieces
";




if ($#ARGV < 0)
{
    print $usage;
    exit;
}

$file = $ARGV[0];

unless (-e $file)
{
    print $usage;
    exit;
}

# clean out the package directory
# `\\rm package/*`;

# find figures

$outfile = "package/$file";
open (FILE,$file) or die "can't open $file: $!\n";
open (OUTFILE,">$outfile") or die "can't open $outfile: $!\n";

$i = 1;
foreach $line (<FILE>)
{
    unless ($line =~ m/\s*%/) {
	if ($line =~ m/\\includegraphics\[.*?\]\{(.*?)\}/) {
	    push @figures, $1;

	    if ($i<10) {$fignum = "00$i";} 
	    elsif ($i<100) {$fignum = "0$i";}
	    else {$fignum = $i;}
	    $prefix = "fig".$fignum."_";
	    $line =~ s/(\\includegraphics.*?)\{(.*?)\}/$1\{$prefix$2\}/;
	    $i = $i + 1;
	}
    }
    print OUTFILE $line;
}

close FILE;
close OUTFILE;

foreach $i (0..$#figures) {
    $figure = $figures[$i];
    $tmp = `find . -follow -name $figure -print 2>/dev/null`;
    @tmp = split("\n",$tmp);
    $fullfigures[$i] = $tmp[0];
    chomp($fullfigures[$i]);
}

$i=1;
foreach $fullfigure (@fullfigures) {
    ($figname = $fullfigure) =~ s/.*\///;
    $fignum = sprintf("%03d",$i);
    $prefix = "fig".$fignum."_";
    `cp $fullfigure package/$prefix$figname`;
    `ln -s ../$fullfigure package/.`;
    $i = $i+1;
}
