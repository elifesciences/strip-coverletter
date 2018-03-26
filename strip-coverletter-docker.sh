#!/bin/bash
set -eu

in=$(realpath $1)
bname_in=${in##*/} # /foo/bar/baz.pdf = baz.pdf

out=$2
out_dir=$(dirname $out)
bname_out=${out##*/}

work_dir="/tmp/decap"
logfile="$work_dir/$bname_in.log" # ll: /tmp/decap/baz.pdf.log

mkdir -p vol $work_dir

function finish {
    retcode=$?
    if [[ $retcode > 0 ]]; then
        # command has failed and a dump file was created
        # move the dump file out of vol/ into the tmp dir
        mv vol/$bname_in.dump.tar $work_dir
        echo "failed $retcode"
    fi
}
trap finish EXIT

# 20 minutes, length of PackagePOA timeout
duration=1200
timeout --preserve-status $duration \
    docker run \
        --volume $(pwd):/data \
        --volume $in:/data/$bname_in \
        --user $(id -u $(whoami)) \
        strip-coverletter /data/$bname_in /data/vol/$bname_out > $logfile 2>&1

# move final file to original destination    
mv "vol/$bname_out" $out

# remove log file
rm "$logfile"
