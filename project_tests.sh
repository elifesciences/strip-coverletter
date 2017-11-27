#!/bin/bash
set -e

docker run -it -v $(pwd):/data -u $(id -u $(whoami)) strip-coverletter /data/10012_1_merged_1431494755.pdf /data/out.pdf
