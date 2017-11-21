#!/bin/bash
# calls strip-coverletter.sh on all pdf files in given directory
# there shouldn't be any failures

set -e
trap ctrl_c INT

function ctrl_c() {
    echo "ctrl-c caught"
    exit 1
}

#

pdfdir=$1
if [ -z "$pdfdir" ]; then
    echo "Usage: ./test.sh <pdfdir>"
    exit 1
fi

outdir="$pdfdir-decap"
mkdir -p $outdir

#

for pdffile in `ls $pdfdir/*.pdf`; do
    fname=${pdffile##*/}
    in=$pdffile
    out="$outdir/$fname"
    if [ -e $out ]; then
        echo "found $out, skipping"
        continue
    fi
    if ! ./strip-coverletter.sh $in $out; then
        echo "====================="
        echo "FAILURE with: ./strip-coverletter.sh $in $out"
        cat /tmp/$fname-exploded/log
        echo "====================="
    fi
done
