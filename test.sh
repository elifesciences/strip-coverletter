#!/bin/bash
mkdir -p bucket && cd bucket
aws s3 sync s3://elife-ejp-poa-delivery .

rm -f tmp/*
rmdir tmp/

for file in `ls *.zip`; do
    if ! unzip -t $file 2> /dev/null; then
        echo "broken zip: $file"
        continue
    fi
    unzip -o $file -d tmp
    # remove all the noise
    for subfile in `find tmp/ -type f | grep -v _merged_`; do
        rm $subfile
    done;
    # test the remaining pdf
    sh ../strip-coverletter.sh `ls tmp/*.pdf`
    
    rm -f tmp/*
    rmdir tmp
    
done
