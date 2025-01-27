#!/usr/bin/perl

## adapted to the PoCSverse

#############################################
## localizes figures and text snippet inputs
#############################################

if ($#ARGV<0) {
    exit;
}

@files = @ARGV;

$usage = "
usage: localizify.pl foo1.tex [foo2.tex foo3.tex] ...

does two things:

1. finds and localizes all figures found in input files

- searches for all matches to \includegraphics
- also searches for
 - everything in pocsverse-forced-figures.tex
 - \changelecturelogo
- will not search if file exists in figures/localized-links
- finds first match in figures tree
  and stores in figures/localized
- ignores figures/localized and figures/localized-links
- ignores figure names with variables/commands in them (force include these)
- creates symbolic link in figures/localized-links
- copies everything in figures/localized-links to figures/localized

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

$localfigureslinkdir = "figures/localized-links";
`mkdir -p $localfigureslinkdir`;

$localinputsdir = "inputs/localized";
`mkdir -p $localinputsdir`;

$localinputslinkdir = "inputs/localized-links";
`mkdir -p $localinputslinkdir`;

## figures
$text = `grep -h "figures/localized" @files 2>/dev/null`;

## print $text;

@lines = split('\n',$text);
foreach $line (@lines) {

    if ($line =~ m/^\s*%.*$/) {
        $line = "";
    }

##    print $line."\n";

    ## simpler, better: just look for figures/localized
    if ($line =~ m/\{figures\/localized\/(.*?)\}/) {
 	$figfile = $1;
 	unless ($figfile =~ m/\\/) {
 	    push @figures, $figfile;
 	}
     }
    
##     if ($line =~ m/includegraphics\[.*?\]\{figures\/localized\/(.*?)\}/) {
## 	$figfile = $1;
## 	unless ($figfile =~ m/\\/) {
## 	    push @figures, $figfile;
## 	}
##     }
## 
##     if ($line =~ m/changelecturelogo\{.*?\}\{figures\/localized\/(.*?)\}/) {
## 	$figfile = $1;
## 	unless ($figfile =~ m/\\/) {
## 	    push @figures, $figfile;
## 	}
##     }
    
}

# find first match in tree, could go wrong if multiple versions exist with same name.
# but then you would have failed as a human anyway.
foreach $i (0..$#figures) {
    $figure = $figures[$i];

    if (-e "figures/localized-links/$figure" and -e "figures/localized-links/$figure") {
	print "$figure already linked ...\n";
	`\\cp $localfigureslinkdir/$figure $localfiguresdir/.`;	
    } else {
	print "finding $figure ...\n";
	
	$filenames = `find figures -type d -name archive -prune -follow -o -name $figure -print 2>/dev/null`;

	## uses prune per here:
	## https://stackoverflow.com/questions/4210042/how-do-i-exclude-a-directory-when-using-find

	@filenames = split("\n",$filenames);
	@filenames = grep { $_ !~ m/$localfiguresdir/ } @filenames;
	@filenames = grep { $_ !~ m/$localfigureslinkdir/ } @filenames;
	
	$fullfigures[$i] = $filenames[0];
	chomp($fullfigures[$i]);

	##   print "cp $fullfigures[$i] $localfiguresdir/$figure;\n";
	if (-e "$fullfigures[$i]") {
	    `ln -sf ../../$fullfigures[$i] $localfigureslinkdir/`;
	    `\\cp $localfigureslinkdir/$figure $localfiguresdir/.`;
	    print "found $fullfigures[$i] ...\n";
	} else {
	    print "--- (figures) Did not find figure:\n$figures[$i]\n";
	    push @missingfigures, $figures[$i];
	}
    }

}


##############################
## snippet inputs
##############################

$text = `grep \\input @files 2>/dev/null`;


@lines = split('\n',$text);
foreach $line (@lines) {
    $line =~ s/\%.*$//;
    if ($line =~ m/\{inputs\/localized\/(.*?)\}/) {
	$inputfile = $1;
	## print $inputfile."\n";
	## best if txt or tex is fully specified
	## will add tex if not
	unless ($inputfile =~ m/\.t..$/) {
	    $inputfile = $inputfile.".tex";
	}
	## ignore files variables in their name
	## 
	## must be included directly
	if ($inputfile !~ /\\/) {
	    push @inputfiles, $inputfile;
	}
    }
}

foreach $i (0..$#inputfiles) {
    $inputfile = $inputfiles[$i];

    print $inputfile."\n";
    $inputfilenames = `find . -type d -name archive -prune -follow -o -name $inputfile -print 2>/dev/null`;

    @inputfilenames = split("\n",$inputfilenames);
    @inputfilenames = grep { $_ !~ m/$localinputsdir/ } @inputfilenames;
    @inputfilenames = grep { $_ !~ m/$localinputslinkdir/ } @inputfilenames;

    
##    print join("::",@inputfilenames);

##    print "\n";

##    print "- ".$inputfilenames[0];
##    print "\n";    

    ##    print "cp $inputfilenames[0] $localinputsdir/\n";
    if (-e "$inputfilenames[0]") {
	`ln -sf ../../$inputfilenames[0] $localinputslinkdir/`;
	`\\cp $localinputslinkdir/$inputfile $localinputsdir/.`;
    } else {
	print "--- (inputs) Did not find input:\n$i\n$inputfiles[$i]\n";
    }
}

if ($#missingfigures >= 0) {
    $nummissing = $#missingfigures + 1;
    print "\n$nummissing missing figures:\n";
    foreach $i (0..$#missingfigures) {
	print $missingfigures[$i]."\n";
    }
}
	
