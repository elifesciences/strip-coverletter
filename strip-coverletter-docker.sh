#!/bin/bash
# configures the Docker 'strip-coverletter' container to 
# decap the given PDF and 
# write the result to the given output filename.
set -eu

in=$(realpath "$1") # "/path/to/some.pdf"
bname_in=${in##*/} # basename of "/path/to/some.pdf" => "some.pdf"

out=$2 # "/path/to/write/output/file.pdf"
out_dir=$(dirname "$out") # "/path/to/write/output"
bname_out=${out##*/} # basename of "/path/to/write/output/file.pdf" => "file.pdf"

# lsh@2022-08-02: use external volume mounted at /bot-tmp, if it exists.
# this is easier than modifying elife-bot code.
tmp_dir="/tmp"
if [ -e "/bot-tmp" ]; then
    tmp_dir="/bot-tmp"
fi

# where to write temporary data.
work_dir_root=${3:-$tmp_dir}
work_dir="$work_dir_root/decap" # "/tmp/decap", "/bot-tmp/decap"

logfile="$work_dir/$bname_in.log" # "/tmp/decap/baz.pdf.log"

# creates directories "./vol" "/tmp/decap" "/path/to/write/output"
mkdir -p vol "$work_dir" "$out_dir"

# ./vol needs to be writable by the host user with id 1001
chmod 777 ./vol

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
        strip-coverletter "/data/$bname_in" "/data/vol/$bname_out" \
        >"$logfile" 2>&1

# output files must be owned by the calling user
host_id=`id -u`
docker run \
    --rm -it \
    --user root \
    --entrypoint /bin/sh \
    -e HOST_UID=`id -u` \
    -v /data/vol:/tmp \
    strip-coverletter -c 'chown -R ${HOST_UID}:${HOST_UID} /tmp/'

# normalise ownership/permissions of any output. got the idea here:
# https://stackoverflow.com/questions/26500270/understanding-user-file-ownership-in-docker-how-to-avoid-changing-permissions-o/26514736#answer-54317162
docker run \
    --rm -it \
    --user root \
    --entrypoint "/bin/sh" \
    --env HOST_UID=$(id -u) \
    --volume "$(pwd)/vol:/data" \
    strip-coverletter -c 'chown -R ${HOST_UID}:${HOST_UID} /data/'

# move final file to original destination
# mv -f "vol/file.pdf" "/path/to/write/output/file.pdf"
mv -f "vol/$bname_out" "$out"

# remove log file
rm -f "$logfile"
