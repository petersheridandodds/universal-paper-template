#!/usr/bin/perl

$usage = "singlelineify.pl foo1.tex [foo2.tex ...]

- create foo1.txt [foo2.txt ...]
  which are single line versions of the tex versions.

- removes all empty lines, newlines, all commented out sections.

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

foreach $file (<@ARGV>) {

    if ($file =~ m/\.tex$/) {
	($outfile = $file) =~ s/\.tex$/.txt/;

	undef $/;
	open (FILE, "$file") or die "Can't open $file: $!\n";
	$text = <FILE>;
	$text =~ s/\\\\//msg;
	$text =~ s/^\s*\%.*\n//msg;
	$text =~ s/\n/ /msg;
	$text =~ s/ +/ /g;

	open (OUTFILE,">$outfile") or die "Can't open $outfile: $!\n";
	print "Converting $file to $outfile ...\n";
	print OUTFILE $text."\n";
    }

}

