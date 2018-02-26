#!/bin/bash
set -e

infile=$1
outfile=$2

imageres=320
threshold=10

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
   "$infile"
