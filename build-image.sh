#!/bin/bash
set -e

docker build --rm --tag elifesciences/strip-coverletter .
docker tag elifesciences/strip-coverletter "elifesciences/strip-coverletter:${IMAGE_TAG:-latest}"
