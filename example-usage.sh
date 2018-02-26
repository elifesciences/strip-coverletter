#!/bin/bash
set -exv
userid="$(id -u "$(whoami)")"
sudo docker run -v "$(pwd)":/data -u "$userid" strip-coverletter /data/dummy.pdf /data/out.pdf
