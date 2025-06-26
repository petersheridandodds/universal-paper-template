#!/usr/bin/perl

## turns input LaTeX files into single lines
## which are then useable for submission, websites, etc.
##
## (have long done this by hand)

## peter sheridan dodds
## https://github.com/petersheridandodds
## MIT License

$usage = "one-lineify.pl foo1.tex [foo2.tex ...]

- create foo1.txt [foo2.txt ...]
  which are single line versions of the tex versions.

- removes all empty lines, newlines, all commented out sections, textblocks

- for use with 
  .title.tex
  .abs.tex 
  .logline.tex

- will mercilessly clobber .txt versions
";

if ($#ARGV < 0) {
    print $usage;
    exit;
}

foreach $file (@ARGV) {

    if ($file =~ m/\.tex$/) {

	($outfile = $file) =~ s/\.tex$/.txt/;

	undef $/;
	open (FILE, $file) or die "Can't open $file: $!\n";
	$latex = <FILE>;
	close FILE;

	$latex =~ s/^\s*\%.*$//msg;
	$latex =~ s/\\begin{textblock}//msg;
	$latex =~ s/\\end{textblock}//msg;
	$latex =~ s/\\item//msg;
	$latex =~ s/\\bigskip//msg;
	$latex =~ s/\\medskip//msg;
	$latex =~ s/\\smallskip//msg;
	$latex =~ s/\\\\//msg;
	$latex =~ s/^\s*\n//msg;
	$latex =~ s/\n/ /g;
	$latex =~ s/ +/ /g;
	$latex =~ s/^ +//;
	$latex =~ s/ +$//;

	$latex = $latex."\n";

	open (OUTFILE, ">$outfile") or die "Can't open $outfile: $!\n";
	print OUTFILE $latex;
	close OUTFILE;
	

    } else {
	print "$file is not a .tex file ... skipping\n";
    }
    
}
