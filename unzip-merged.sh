#!/bin/bash
# iterate through contents of zipped files in $bucket and extract merged file
set -e

bucketdir=${1:-bucket}
pdfdir="$bucketdir-pdf"
mkdir -p $bucketdir $pdfdir

for pdffile in `ls $bucketdir/*.zip`; do
    echo "$pdffile -> $pdfdir/$merged"
    merged=$(zipinfo -1 $pdffile | grep merged) || echo "- bad zip or a 'merged' pdf not found."
    if [ -z $merged ]; then
        continue
    fi
    if [ -f "$pdfdir/$merged" ]; then
        echo "- skipping, 'merged' pdf exists."
        continue
    fi
    # -o  overwrite existing files without prompting
    # -u  update existing files and create new ones if needed
    # -q  quiet
    unzip -q -o -u $pdffile $merged -d "$pdfdir/"
    test -e $pdfdir/$merged || echo "- failed to find 'merged' pdf to strip."
done

echo "done, now run:

    ./test.sh $pdfdir
"
