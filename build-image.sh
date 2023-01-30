#!/bin/bash
set -e

docker build --rm --tag strip-coverletter .
docker tag strip-coverletter "elifesciences/strip-coverletter:${IMAGE_TAG:-latest}"
