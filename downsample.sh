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

# these don't seem to help much/at all
#   -dNumRenderingThreads=64 \
#   -dBandBufferSpace=500000000 \
#   -sBandListStorage=memory \
#   -dBufferSpace=1000000000 \

timeout --preserve-status $duration \
    gs \
       -o $outfile \
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
       $infile
