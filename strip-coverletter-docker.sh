#!/bin/bash
set -eu
set -xv
in=$(realpath $1)
bname_in=${in##*/} # /foo/bar/baz.pdf = baz.pdf

out=$2
bname_out=${out##*/}

mkdir -p vol
cp $in vol/$bname_in

sudo docker run \
    --volume $(pwd):/data \
    --volume $in:/data/$bname_in \
    --user $(id -u $(whoami)) \
    strip-coverletter /data/$bname_in /data/vol/$bname_out

# move final file to original destination    
mv vol/$bname_out $out
