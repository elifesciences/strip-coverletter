#!/bin/bash
set -eu

in=$(realpath "$1")
bname_in=${in##*/} # "/foo/bar/baz.pdf" => "baz.pdf"

out=$2
out_dir=$(dirname "$out")
bname_out=${out##*/}

# lsh@2022-08-02: default to the external volume mounted at /bot-tmp, if it exists.
# this is easier than modifying elife-bot code.
tmp_dir="/tmp"
if [ -e "/bot-tmp" ]; then
    tmp_dir="/bot-tmp"
fi

work_dir_root=${3:-$tmp_dir}
work_dir="$work_dir_root/decap" # "/tmp/decap", "/bot-tmp/decap"
logfile="$work_dir/$bname_in.log" # "/tmp/decap/baz.pdf.log"

mkdir -p vol "$work_dir" "$out_dir"

function finish {
    retcode=$?
    if [[ $retcode -gt 0 ]]; then
        # command has failed and a dump file was created
        # move the dump file out of vol/ into the tmp dir
        mv "vol/$bname_in.dump.tar" "$work_dir"
        echo "failed: $retcode"
        echo "wrote $work_dir/$bname_in.dump.tar"
        echo "wrote $work_dir/$bname_in.log"
    fi
}
trap finish EXIT

# 20 minutes, length of PackagePOA timeout
duration=1200
timeout --preserve-status $duration \
    docker run \
        --rm \
        --volume "$(pwd):/data" \
        --volume "$in:/data/$bname_in" \
        strip-coverletter "/data/$bname_in" "/data/vol/$bname_out" > "$logfile" 2>&1

# move final file to original destination    
mv -f "vol/$bname_out" "$out"

# remove log file
rm -f "$logfile"
