#!/bin/bash

if [ "$1" -eq "" ]; then
    echo "Usage: ./test.sh <pdfdir>"
    exit 1;
fi;

for pdffile in `ls $1/*.pdf`; do
    if ! sh strip-coverletter.sh $pdffile; then 
        echo "FAILURE in $pdffile"
        #break
    fi
    echo ""
done;
