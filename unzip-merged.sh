#!/bin/bash
# iterate through contents of zipped files in $bucket
# extract contents, run strip-coverletter, delete contents

set -e
#set -vx

bucketdir=${1:-bucket}
pdfdir="$bucketdir-pdf"
mkdir -p $bucketdir $pdfdir

for pdffile in `ls $bucketdir/*.zip`; do
    merged=$(zipinfo -1 $pdffile | grep merged) || echo "bad zip or a 'merged' pdf not found: $pdffile"
    if [ -z $merged ]; then
        continue
    fi

    echo "$pdffile -> $pdfdir/$merged"
    # -o  overwrite existing files without prompting
    # -u  update existing files and create new ones if needed
    # -q  quiet
    unzip -q -o -u $pdffile $merged -d "$pdfdir/"
    test -e $pdfdir/$merged || echo "failed to find merge file $pdfdir/$merged"
done

echo "done, now run:

    ./test.sh $pdfdir
"
