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
        # looks for lines starting with '1' followed by 0 or 1 chars and then ends
        # examples with more whitespace then ends:
        # bucket-pdf/6117_1_merged_pdf_82383_nd6nzc.pdf
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
    # if pdftotext can't find any text, for example if text has been converted 
    # to paths, then we'll get here and exit.

    # TODO: investigate possibility of splitting by bookmarks
    # some but not all of these files have bookmarks like 'Cover Page', 'Article File'
    # this command on this file creates two files, the first is the covering letter, the second the article
    # sejda-console splitbybookmarks -f bucket-pdf/7142_1_merged_pdf_101005_nhp9w3.pdf -l 1 -o tmp/ -e "Article File"

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

echo "thinking ..."

decap_bytes=$(du --bytes $output_pdf | cut --fields 1)
squashed_bytes=$(du --bytes $squashed_pdf | cut --fields 1)
savings_bytes=$((decap_bytes-squashed_bytes))

echo "- decapped: $decap_bytes"
echo "- squashed: $squashed_bytes"
echo "- savings:  $savings_bytes ($((($savings_bytes/1024)/1024))MB)"

# only use the squashed pdf if it's smaller than the decapped version
if [ $((decap_bytes>squashed_bytes)) == 1 ]; then
    echo "- preferring squashed"
    mv $squashed_pdf $output_pdf
else
    echo "- preferring decapped"
    rm "$squashed_pdf"
fi

echo 'removing temporary files+dir ...'
rm $explodeddir/*
rmdir $explodeddir
echo "- all done  •ᴗ•"
