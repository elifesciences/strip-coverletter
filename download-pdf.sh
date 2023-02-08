#!/bin/bash
# downloads the *entire* bucket locally.
# this used to be a small operation when POAs were new.
# use ctrl-c to cancel operation
set -e
mkdir -p bucket
cd bucket
echo "downloading, ctrl-c to cancel"
aws s3 sync s3://elife-ejp-poa-delivery .
