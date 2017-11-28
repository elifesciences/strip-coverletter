#!/bin/bash
set -e

sudo docker run -v $(pwd):/data -u $(id -u $(whoami)) strip-coverletter /data/dummy.pdf /data/out.pdf
