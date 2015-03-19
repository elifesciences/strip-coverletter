#!/bin/bash
mkdir -p bucket && cd bucket
#aws s3 sync s3://elife-ejp-poa-delivery .

unzipdir=unzipped

#rm -f $unzipdir/*
#rmdir $unzipdir

# extract the _merged_ pdf from the zip file
for file in `ls *.zip`; do
    # test integrity of zip file, skip if it looks bad
    if ! unzip -t $file 2>/dev/null 1>/dev/null; then
        echo "broken zip: $file"
        continue
    fi
    
    unzip -o -B $file *_merged_* -d $unzipdir 2>/dev/null 1>/dev/null
    
done

# test the pdfs
for pdffile in `ls $unzipdir/*.pdf`; do
    if ! sh ../strip-coverletter.sh $pdffile; then 
        echo "failure in $pdffile"
        break
    fi
    echo ""
done;
