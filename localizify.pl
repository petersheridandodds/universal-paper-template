#!/usr/bin/perl

#############################################
## localizes figures and text snippet inputs
#############################################

$usage = "
usage: localizify.pl

does two things:

1. finds and localizes all figures found in:

*.body.tex *.supplementary.tex *.appendix.tex

- searches for all matches to includegraphics
- finds first match in figures tree
  and stores in figures/localized
- ignores figures/localized
- overwrites figures

2. finds and localizes all input text files in *.settings.tex

- signal to do this by explicitly using \input{inputs/localized/...}
- stores in inputs/localized/
- expects snippets to be in ./figures tree only

";

##############################
## figures
##############################

$localfiguresdir = "figures/localized";
`mkdir -p $localfiguresdir`;

$localinputsdir = "inputs/localized";
`mkdir -p $localinputsdir`;

$text = `grep includegraphics *.body.tex *.supplementary.tex *.appendix.tex 2>/dev/null`;

@lines = split('\n',$text);
foreach $line (@lines) {
    $line =~ s/\%.*$//;

    if ($line =~ m/includegraphics\[.*?\]\{$localfiguresdir\/(.*?)\}/) {
	push @figures, $1;
    }
}

# find first match in tree, could go wrong if multiple versions exist with same name.
# but then you would have failed as a human anyway.
foreach $i (0..$#figures) {
    $figure = $figures[$i];
	    
    $filenames = `find figures -follow -name $figure -print 2>/dev/null`;
    @filenames = split("\n",$filenames);
    @filenames = grep { $_ !~ m/$localfiguresdir/ } @filenames;
    
    $fullfigures[$i] = $filenames[0];
    chomp($fullfigures[$i]);

    ##   print "cp $fullfigures[$i] $localfiguresdir/$figure;\n";
    if (-e "$fullfigures[$i]") {
	`cp $fullfigures[$i] $localfiguresdir/$figure`;
    } else {
	print "Did not find:\n$figures[$i]\n";
    }
}

##############################
## snippet inputs
##############################

$text = `grep \\input *.settings.tex *.body.tex *.supplementary.tex *.appendix.tex 2>/dev/null`;

@lines = split('\n',$text);
foreach $line (@lines) {
    $line =~ s/\%.*$//;
    if ($line =~ m/\\input\{$localinputsdir\/(.*?)\}/) {
	$inputfile = $1;
	## best if txt or tex is fully specified
	## will add tex if not
	unless ($inputfile =~ m/\.t..$/) {
	    $inputfile = $inputfile.".tex";
	}
	push @inputfiles, $inputfile;
    }
}
foreach $i (0..$#inputfiles) {
    $inputfile = $inputfiles[$i];
    $inputfilenames = `find figures -follow -name $inputfile -print 2>/dev/null`;
    @inputfilenames = split("\n",$inputfilenames);

    ##    print "cp $inputfilenames[0] $localinputsdir/\n";
    if (-e "$inputfilenames[0]") {
	`cp $inputfilenames[0] $localinputsdir/`;
    } else {
	print "Did not find\n:$inputfiles[$i]\n";
    }
    
}

