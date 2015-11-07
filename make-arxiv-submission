#!/usr/bin/perl
$usage = "make-arxiv-submission foo as in foo-revtex4.tex\n";

$basefilename = $ARGV[0];

print "making a single latex file...\n";
`make-single-latex-file.pl $basefilename-revtex4.tex`;
print "finding figures and linking...\n";
`makelinks.pl $basefilename-revtex4-combined.tex`;
print "making package...\n";
`makepackage $basefilename`;

