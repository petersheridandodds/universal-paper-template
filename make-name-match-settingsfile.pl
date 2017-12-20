#!/usr/bin/perl

@files = <*-revtex4.tex>;

foreach $file (@files) {
    $file =~ m/^(.*?)-revtex4.tex/;
    $papername = $1;

    $settingsfile = $papername."-revtex4.settings.tex";

    open (SETTINGSFILE, ">$settingsfile") or die "Can't open $settingsfile: $!\n";

    print SETTINGSFILE "\\newcommand{\\filenamebase}{$papername}\n";
    
    close SETTINGSFILE;
    

}


