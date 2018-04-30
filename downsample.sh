#!/bin/bash
set -e

infile=$1
outfile=$2
duration=${3:-600} # default is 10 minutes

imageres=320
threshold=10

# called when this script is done
# when last command fails a dump file is written using the given output filename
function finish {
    retcode=$?
    if [[ $retcode > 0 ]]; then
        echo "downsample failed with $retcode, cleaning up"
        rm -f "$outfile"
    fi
}
trap finish EXIT

# reads stdout from `gs` and looks for error strings
# exits with status 2 if one detected
# strip-coverletter.sh catches any errors and will prefer decap over squashed
function detect_errors {
    while read line; do
        echo "$line"

        # reset error
        error=""

        # "**** Error reading a content stream. The page may be incomplete."
        if [[ "$line" == "**** Error: "* ]]; then
            error=$line
        fi

        # "Output may be incorrect."
        if [ "$line" = "Output may be incorrect." ]; then
            error=$line
        fi

        # if the value of error is not empty, fail
        if [ ! -z "$error" ]; then
            echo ""
            echo "detected imperfect squash: $error"
            exit 2
        fi
    done
}

# these don't seem to help much/at all
#   -dNumRenderingThreads=64 \
#   -dBandBufferSpace=500000000 \
#   -sBandListStorage=memory \
#   -dBufferSpace=1000000000 \

timeout --preserve-status $duration \
    gs \
       -o "$outfile" \
       -sDEVICE=pdfwrite \
       -dDownsampleColorImages=true \
       -dDownsampleGrayImages=true \
       -dDownsampleMonoImages=true \
       -dColorImageResolution=$imageres \
       -dGrayImageResolution=$imageres \
       -dMonoImageResolution=$imageres \
       -dColorImageDownsampleThreshold=$threshold \
       -dGrayImageDownsampleThreshold=$threshold \
       -dMonoImageDownsampleThreshold=$threshold \
       -dAutoRotatePages=/None \
       "$infile" | detect_errors
