#!/bin/bash

description="script that detects and removes the leading cover sheet from the 
             special article PDF sent to peer reviewers"

author="Luke Skibinski <l.skibinski@elifesciences.org>"
copyright="eLife Sciences"
license="GNU GPLv3"

if [ ! -f /usr/bin/pdftotext ]; then
    echo "'pdftotext' not found."
    echo "For Ubuntu, install 'xpdf-utils'"
    echo "For Arch, install 'xpdf'"
    exit 1
fi

if [ ! -f /usr/bin/pdfsam-console ]; then
    echo "'pdfsam-console' not found."
    echo "For Ubuntu, follow installation directions:"
    echo "   http://www.sysads.co.uk/2014/08/install-pdfsam-2-2-4-on-ubuntu-14-04/"
    echo "For Arch, install 'pdfsam'"
    exit 1;
fi

if [[ ! $1 ]] || [[ ! -f $1 ]]; then
    echo "Usage: ./strip-coverletter.sh <pdf>"
    exit 1;
fi

pdf=$(basename $1);
explodeddir=/tmp/$pdf-exploded
total_pages="`pdfinfo $1 | grep 'Pages:' | grep -Eo '[0-9]{1,2}'`"
output_pdf="/tmp/ncl-$pdf"
mkdir $explodeddir

echo 'exploding pdf into individual files'
pdfsam-console -f $1 -o $explodeddir -S BURST -overwrite split > /dev/null

echo 'looking for non-cover pages...'
ncp=-1 # non-cover page
cd $explodeddir
for i in {2..7}; do # first page is guaranteed to be part of the cover letter...
    echo converting page ${i} to text...
    pdftotext $explodeddir/$i\_$pdf $explodeddir/tmp.txt
    for j in {1..9}; do
        match="`cat $explodeddir/tmp.txt | grep "^$j$" | head -n 1`"
        if [ "$match" = "" ]; then
            echo page ${i} is a cover letter, skipping.
            break
        else
            #echo "match found for line starting with '$j'"
            ncp=$i
        fi
    done
    if [ "$ncp" -gt -1 ]; then
        echo "article begins at page $ncp"
        break
    fi
done

echo "writing pdf to $output_pdf ... "
i=$ncp
pathargs=""
while [ "$i" -le "$total_pages" ]; do
    pathargs="$pathargs -f $explodeddir/$i\_$pdf"
    i=$(( $i + 1 ))
done
cmd="pdfsam-console -o $output_pdf $pathargs concat > /dev/null"
eval $cmd

echo 'removing temporary files+dir ...'
rm $explodeddir/*
rmdir $explodeddir
