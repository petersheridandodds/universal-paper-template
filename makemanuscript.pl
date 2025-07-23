#!/usr/bin/perl

`mkdir -p log`;

$filetype = "manuscript";

## set up name in settings file
`make-name-match-settingsfile.pl`;

## localize figures and inputs (for better sharing and also overcomes legacy figure search slowness)
`./localizify.pl`;

## local directory (for global recording of writing data)
## works because paper/book directory names are in the format YYYY-MM-descriptive-tags
## downfall: directory names may change but that represents a rebuilding
$fulldir = $ENV{'PWD'};
($localdir = $ENV{'PWD'}) =~ s/^.*\///;

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
$monthnum = $month + 1;
$year += 1900;
$timestamp = "$year $monthnum $numday $hour $min $sec";

foreach $body (@bodies) {
    ($filename = $body) =~ s/\.body\.tex$//;
    ($supplementaryfilename = $body) =~ s/\.body\.tex$/\.supplementary\.tex/;
    ($appendiexfilename = $body) =~ s/\.body\.tex$/\.appendix\.tex/;
    if (-e "$filename-manuscript.tex") {

	## make local bibliography
	## will need to be adjusted for more elaborate inputs
	$texfiles = join(" ",<$filename.*.tex>);
	$command = "make-local-bibfile.pl $filename.bib $texfiles";
        system($command);

	## onelineify title, logline, and abstract
	`singlelineify.pl $filename.title.tex`;
	`singlelineify.pl $filename.logline.tex`;
	`singlelineify.pl $filename.abs.tex`;
	`singlelineify.pl $filename.acknowledgments.tex`;

	($logfilename = "log/progress-$body") =~ s/\.body\.tex$/-log/;
	print "processing $filename...\n";

	## create $filename-manuscript.settings.tex file
	$settings = "$filename-manuscript.settings.tex";
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
	    `pdflatex $filename-manuscript 1>&2`;
	}
	else {
	    `latex $filename-manuscript 1>&2`;
	}
	unless ($quickswitch == 1) {
	    `bibtex $filename-manuscript 1>&2`;
	    if ($pdfswitch == 1) {
		`pdflatex $filename-manuscript 1>&2`;
		`pdflatex $filename-manuscript 1>&2`;
	    }
	    else {
		`latex $filename-manuscript 1>&2`;
		`latex $filename-manuscript 1>&2`;
	    }
	}
	if ($pdfswitch == 0) {
	    `dvips -o $filename-manuscript.ps $filename-manuscript 1>&2`;
	    `epstopdf $filename-manuscript.ps 1>&2`;
	}

	## if open, bring to front
        `open $filename-manuscript.pdf`;
	## `open -a preview`;

##	$numtodos = `countcheckboxes $filename.abs.tex $filename.body.tex $filename.appendix.tex $filename.supplementary.tex 1>&2`;

	`countcheckboxes $filename.*.tex 1>&2`;
	$numtodos = `countcheckboxes-total $filename.*.tex`;
	chomp $numtodos;

	## extract page and byte numbers
	$texlogfile = $filename."-manuscript.log";
	open (TEXLOGFILE, "$texlogfile") or die "can't open $texlogfile: $!\n";
	
	undef $/;
	$log = <TEXLOGFILE>;
	$log =~ m/Output written on (.*\)[\.]*)$/ms;
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
	    $centrallogfile = sprintf("$ENV{HOME}/papers/log/writing/%d-%02d.txt",$year,$monthnum);
	    `touch $centrallogfile`;
	    open (CENTRALLOGFILE,">>$centrallogfile") or die "Can't open $centrallogfile: $!\n";

	    print CENTRALLOGFILE "$timestamp $numtodos $numpages $numbytes $numlines $numwords $numchars $fulldir $filename $filetype \n";
	    close CENTRALLOGFILE;
	    
	    open (LOGFILE, ">>$logfilename") or die "Can't open $logfilename: $!\n";
	    print LOGFILE "$timestamp $numtodos $numpages $numbytes $numlines $numwords $numchars\n";
	    close LOGFILE;
	    print "\nData logged\n";
	}
	else
	{
	    print "\n\nWarning! No data logged!\n\n";
	}
	
	$citenum = `grep \"Warning--I didn\'t find a database entry for\" $filename-manuscript.blg | wc -l`;
	$citenum =~ s/\s//g;
	print "Number of missing citations = $citenum\n";

    }

    print "run pdflatex $filename-newpax.tex separately if needed\n";    

}


