#!/bin/zsh

if [[ $# -ne 1 ]]; then
    echo "usage: $0:t paper-name" >&2
    exit 1
fi

filenamebase=$1

mkdir -p latex-package
mkdir -p latex-package/figures/localized
mkdir -p latex-package/inputs/localized

\cp -R figures/localized/* latex-package/figures/localized/.

\cp \
    $filenamebase-manuscript.tex \
    $filenamebase-manuscript.author.tex \
    $filenamebase.abs-long.tex \
    $filenamebase.acknowledgments.tex \
    $filenamebase.bib \
    $filenamebase.body.tex \
    $filenamebase.changelog.tex \
    $filenamebase.keywords.tex \
    $filenamebase.logline.tex \
    $filenamebase.published-reference.tex \
    $filenamebase.settings.tex \
    $filenamebase.supplementary.tex \
    $filenamebase.title.tex \
    $filenamebase.bib \
    unsrtabbrv.bst \
    latex-package/.


cd latex-package

## have to tell arXiv files matter because its check is stupid

../stupid/makestupid.pl $filenamebase

## at the moment: remove settings input by hand

tar cvfpz ../$filenamebase-arxiv.tgz *
 
cd ..;
