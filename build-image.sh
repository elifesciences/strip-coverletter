#!/bin/bash
set -e

docker build --tag strip-coverletter .
docker tag strip-coverletter "elifesciences/strip-coverletter:${IMAGE_TAG:-latest}"
