#!/bin/bash

set -e

# always start in the script's dir
cd "$(dirname "$0")"

# use the local sejda-console rather than rely on one being installed
PATH="sejda-console/bin:$PATH" 

description="script that detects and removes the leading cover sheet from the 
             special article PDF sent to peer reviewers"

author="Luke Skibinski <l.skibinski@elifesciences.org>"
copyright="eLife Sciences"
license="GNU GPLv3"

errcho() { echo "$@" 1>&2; } # for errors

if [ ! -f /usr/bin/pdftotext ]; then
    errcho "'pdftotext' not found."
    errcho "For Ubuntu, install 'xpdf-utils'"
    errcho "For Arch, install 'xpdf'"
    exit 1
fi

if ! type -P sejda-console > /dev/null; then
    errcho "'sejda-console' not found."
    errcho "For Ubuntu, follow installation directions:"
    errcho "   http://www.sysads.co.uk/2014/08/install-pdfsam-2-2-4-on-ubuntu-14-04/"
    errcho "For Arch, install 'pdfsam'"
    exit 1;
fi

if [[ ! $1 ]] || [[ ! -f $1 ]] || [[ ! $2 ]]; then
    errcho "Usage: ./strip-coverletter.sh <in-pdf> <out-pdf>"
    exit 1;
fi

pdf=$(basename $1);
tempdir=/tmp
explodeddir=$tempdir/$pdf-exploded # note! /temp and not /tmp 

echo "exploding to $explodeddir"
mkdir -p $explodeddir
touch $explodeddir/log

total_pages="`pdfinfo $1 | grep 'Pages:' | grep -Eo '[0-9]+'`"
output_pdf=$(readlink -f "$2")

sejda-console simplesplit --files $1 --output $explodeddir --existingOutput overwrite --predefinedPages all > $explodeddir/log

echo 'looking for non-cover pages...'
ncp=-1 # non-cover page
for i in {2..7}; do # first page is guaranteed to be part of the cover letter...
    echo "- converting page $i to text..."
    for j in {1..9}; do
        #match="`cat $explodeddir/tmp.txt | grep "^$j$" | head -n 1`"
        # this has a *slightly* more flexible regex
        match="`pdftotext $explodeddir/$i\_$pdf /dev/stdout | grep -Ex "^1.{0,1}$" | head -n 1`"
        if [ "$match" = "" ]; then
            echo "- page $i is a cover letter"
            break
        else
            #echo "match found for line starting with '$j'"
            ncp=$i
        fi
    done
    if [ "$ncp" -gt -1 ]; then
        echo "- article begins at page $ncp!"
        break
    fi
done

if [ ! "$ncp" -gt -1 ]; then
    errcho "failed to detect end of cover letter!"
    exit 1
fi

echo "writing pdf ..."
i=$ncp
pathargs=""
#echo "endofcoverletter='$i' totalpages='$total_pages'"
while [ "$i" -le "$total_pages" ]; do
    pathargs="$pathargs $explodeddir/$i\_$pdf"
    i=$(( $i + 1 ))
done

cmd="sejda-console merge --files $pathargs --output $output_pdf --overwrite >> $explodeddir/log 2>&1"
eval $cmd
echo "- wrote $output_pdf"

echo 'squashing pdf ...'

squashed_pdf="$output_pdf-squashed.pdf"
./downsample.sh $output_pdf $squashed_pdf >> $explodeddir/log 2>&1
echo "- wrote $squashed_pdf"

echo 'removing temporary files+dir ...'
rm $explodeddir/*
rmdir $explodeddir
echo "- all done  •ᴗ•"
