#!/usr/bin/env perl

use strict;
use warnings;
use File::Basename qw(basename);

my $filenamebase = shift @ARGV;
die "usage: " . basename($0) . " filename-base\n"
    unless defined $filenamebase && !@ARGV;

## operate on all matching .tex files in the current directory
@ARGV = glob("$filenamebase-manuscript.tex");
die "no files matching $filenamebase-manuscript.tex\n" unless @ARGV;

$^I = '';                          # in-place edit, no backup
local $/;                          # slurp each file whole so the block matches across lines

while (<>) {
    # remove the three-line currfile preamble block, wherever it appears
    s/
        ^ \Q%% load in root name\E               \r?\n
          \Q\usepackage[realmainfile]{currfile}\E \r?\n
          \Q\input{\currfilebase.settings}\E       \r?\n
    //mgx;

    # remaining macro substitutions
    s/\\currfilebase/$filenamebase-manuscript/g;
    s/\\filenamebase/$filenamebase/g;

    print;
}
