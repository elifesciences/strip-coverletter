#!/bin/bash
set -e

infile=$1

imageres=320
threshold=10

gs \
   -o downsampled.pdf \
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
   $infile
