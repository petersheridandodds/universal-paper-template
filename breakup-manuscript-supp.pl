#!/usr/bin/perl

$pdffile = $ARGV[0];
($manufile = $pdffile) =~ s/\.pdf$/-manuscript.pdf/;
($suppfile = $pdffile) =~ s/\.pdf$/-supplementary.pdf/;

$supp_firstpage = `cat startsupp.txt`;
chomp($supp_firstpage);
$manulastpage = $supp_firstpage - 1;

$pdfinfo = `pdfinfo $pdffile`;
$pdfinfo =~ m/^Pages:\s+?(\d+)\s/ms;
$lastpage = $1;

`gs -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -dSAFER -dFirstPage=1 -dLastPage=$manulastpage -sOutputFile=$manufile $pdffile $1>&2`;

`gs -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -dSAFER -dFirstPage=$supp_firstpage -dLastPage=$lastpage -sOutputFile=$suppfile $pdffile $1>&2`;


