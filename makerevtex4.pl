#!/usr/bin/perl

## set up name in settings file
`make-name-match-settingsfile.pl`;

## localize figures and inputs (for better sharing)
`./localizify.pl`;

## local directory (for global recording of writing data)
## works because paper/book directory names are in the format YYYY-MM-descriptive-tags
## downfall: directory names may change but that represents a rebuilding
$fulldir = `pwd`;
($localdir = `pwd`) =~ s/^.*\///;

foreach $argument (@ARGV) {
    if (($argument eq "-quick") or ($argument eq "-q"))
    {
	$quickswitch = 1;
    } elsif ($argument =~ m/\.body\.tex$/) {
	@bodies = (@bodies, $argument);
    }
}

if ($#bodies eq -1) {
    $bodylist = `ls *.body.tex`;
    @bodies = split(/\s+/,$bodylist);
}

($sec,$min,$hour,$numday,$month,$year,$wday,$yday,$isdst) = localtime(time);
$year += 1900;
$timestamp = "$year $month $numday $hour $min $sec";

foreach $body (@bodies) {
    ($filename = $body) =~ s/\.body\.tex$//;
    ($supplementaryfilename = $body) =~ s/\.body\.tex$/\.supplementary\.tex/;
    ($appendiexfilename = $body) =~ s/\.body\.tex$/\.appendix\.tex/;
    if (-e "$filename-revtex4.tex") {

	## make local bibliography
	## will need to be adjusted for more elaborate inputs
	$texfiles = join(" ",<$filename.*.tex>);
	$command = "make-local-bibfile.pl $filename.bib $texfiles";
        system($command);

	## make single line versions of title, abstract, logline
	$command = "./singlelineify.pl $filename.title.tex\n";
        system($command);
	$command = "./singlelineify.pl $filename.abs.tex\n";
        system($command);
	$command = "./singlelineify.pl $filename.logline.tex\n";
        system($command);

	($logfilename = "log/progress-$body") =~ s/\.body\.tex$/-log/;
	print "processing $filename...\n";

	## create $filename-revtex4.settings.tex file
	$settings = "$filename-revtex4.settings.tex";
	open (SETTINGS,">$settings") or die "can't open $settings: $!\n";
	print SETTINGS "\\newcommand{\\filenamebase}{$filename}\n";
	close SETTINGS;

	## check for postscript
	open (BODY, "$body") or die "can't open $body: $!\n";
	undef $/;
	$bodytex = <BODY>;
	close BODY;
	if ($bodytex =~ m/\.ps\}/msg) {
	    $pdfswitch = 0;
	}
	else {
	    $pdfswitch = 1;
	}
	    
	if ($pdfswitch == 1) {
	    `pdflatex $filename-revtex4 1>&2`;
	}
	else {
	    `latex $filename-revtex4 1>&2`;
	}
	unless ($quickswitch == 1) {
	    `bibtex $filename-revtex4 1>&2`;
	    if ($pdfswitch == 1) {
		`pdflatex $filename-revtex4 1>&2`;
		`pdflatex $filename-revtex4 1>&2`;
	    }
	    else {
		`latex $filename-revtex4 1>&2`;
		`latex $filename-revtex4 1>&2`;
	    }
	}
	if ($pdfswitch == 0) {
	    `dvips -o $filename-revtex4.ps $filename-revtex4 1>&2`;
	    `epstopdf $filename-revtex4.ps 1>&2`;
	}

	## if open, bring to front
        `open $filename-revtex4.pdf`;
	## `open -a preview`;

##	$numtodos = `countcheckboxes $filename.abs.tex $filename.body.tex $filename.appendix.tex $filename.supplementary.tex 1>&2`;

	`countcheckboxes $filename.*.tex 1>&2`;
	$numtodos = `countcheckboxes-total $filename.*.tex`;
	chomp $numtodos;

	## extract page and byte numbers
	$texlogfile = $filename."-revtex4.log";
	open (TEXLOGFILE, "$texlogfile") or die "can't open $texlogfile: $!\n";
	
	undef $/;
	$log = <TEXLOGFILE>;
	$log =~ m/Output written on (.*\)\.)$/ms;
	($line = $1) =~ s/\n//g;
##    print "$line\n";
	$line =~ m/\((\d+) (pag.*?), (\d+) bytes\)/;
	$numpages = $1;
	$numbytes = $3;

	close TEXLOGFILE;

	## extract line, word, character counts
	$numlines = `cat $filename.*.tex | wc -l`;
	$numwords = `cat $filename.*.tex | wc -w`;
	$numchars = `cat $filename.*.tex | wc -c`;

	$numlines =~ s/\s+//g;
	$numwords =~ s/\s+//g;
	$numchars =~ s/\s+//g;

	chomp $numlines;
	chomp $numwords;
	chomp $numchars;

		print "$numlines $numwords $numchars";


	if (($numpages ne "") and ($numbytes ne "")) {
	    open (LOGFILE, ">>$logfilename") or die "Can't open $logfilename: $!\n";
	    print LOGFILE "$timestamp $numtodos $numpages $numbytes $numlines $numwords $numchars\n";
	    close LOGFILE;
	    print "Data logged\n";
	}
	else
	{
	    print "No data logged\n";
	}
	
	$citenum = `grep \"Warning--I didn\'t find a database entry for\" $filename-revtex4.blg | wc -l`;
	$citenum =~ s/\s//g;
	print "Number of missing citations = $citenum\n";

    }

}
