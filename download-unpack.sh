#!/bin/bash
mkdir -p bucket && cd bucket
echo "downloading"
aws s3 sync s3://elife-ejp-poa-delivery .

unzipdir=unzipped

rm -f $unzipdir/*
rmdir $unzipdir

echo "extracting"
# extract the _merged_ pdf frm the zip file
for file in `ls *.zip`; do
    # test integrity of zip file, skip if it looks bad
    if ! unzip -t $file 2>/dev/null 1>/dev/null; then
        echo "broken zip: $file"
        continue
    fi
    
    unzip -o -B $file *_merged_* -d $unzipdir 2>/dev/null 1>/dev/null
    echo unzipped $file
done

